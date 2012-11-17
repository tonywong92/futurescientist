require 'set'

class ProblemsController < ApplicationController

  TEXTLENGTH = 160

  def index
    @sessionSkills = []
    @sessionAddresses = []
    skills = params[:skills] || session[:skills] || {}
    addresses = params[:address] || session[:address] || {}
    if addresses == {}
      addresses = ["All"]
    end
    if skills == {}
      skills = ["All"]
    end
    if params[:skills] != session[:skills]
      session[:skills] = skills
      session[:address] = addresses
      flash.keep
      redirect_to :skills => skills, :address => addresses and return
    end
    if params[:address] != session[:address]
      session[:skills] = skills
      session[:address] = addresses
      flash.keep
      redirect_to :skills => skills, :address => addresses and return
    end
    @sessionSkills = skills
    @sessionAddresses = addresses
    if skills.include? "All" and addresses.include? "All"
    @problems = Problem.find(
          :all,
            :order => "created_at DESC")
    elsif skills.include? "All"
  @problems = Problem.where(:location => addresses).order("created_at DESC")
    elsif addresses.include? "All"
  @problems = Problem.where(:skills => skills).order("created_at DESC")
    else
      @problems = Problem.where(:skills => skills, :location => addresses).order("created_at DESC")
    end
    @curr_skills = Problem.select(:skills).uniq
    @curr_addresses = Problem.select(:location).uniq
  end

  def create
    @problem = Problem.new(:location => params[:problem][:location], :summary => params[:problem][:summary], :description => params[:problem][:description], :skills => params[:skills])

    @user = User.find_by_phone_number(params[:user][:phone_number])
    if @user.nil?
      @user = User.new
      @user.attributes = params[:user]
    end
    @user.problems << @problem
    save_problem
    return
  end

  #sms superfunction for receiving texts
  def receive_sms
    @problem_text = params[:Body]
    action = sms_parsing(@problem_text)
    sms_send(@problem_text)
    sms_send(action)
    if !@sms_error
      case action.downcase
        when /^add$/
          sms_create
        when /^accept$/
          sms_accept_problem
        when /^get$/
          @offset = false
          sms_get(0)
        when /^next$/
          offset = session["offset"]
          if offset == nil
            sms_error("Sorry, there is no saved session right now. Please first text \"GET\" with @location !skill %number of texts you want to allow.")
          else
            @offset = true
            sms_get(offset)
          end
        when /^detail$/, /^details$/, /^describe$/
          sms_send("it got in here")
          sms_detail
      end
    end
    sms_send("it got to the end")
    redirect_to get
  end

  #call this to do all the logic to parse the incomming text
  #returns the action that the text wants
  #sets @sms_location if there's a "@location"
  #sets @sms_skills if there's a !skills
  #sets @sms_summary if there's a #summary
  #sets @sms_price if there's a $price
  #sets @sms_limit if there's a LIMIT #
  #sets @sms_error to true if there's a specific error that cannot allow the text to continue processing
  #add more parsing logic here if there's more.
  def sms_parsing(text_body)
    words = text_body.split
    action = words[0]
    words.slice!(0)
    symbol_hashset = Set.new ["!", "@", "#", "$"] #all symbols to check for
    word_hashset = Set.new ["limit"]
    while !words.empty?
      nextWord = words[0]
      symbol = nextWord[0]
      if symbol_hashset.member? symbol
        nextWord.slice!(0)
        case symbol #all symbols to check for here
          when "!"
            @sms_skills = nextWord + " "
            words.slice!(0)
            while !words.empty? and !symbol_hashset.member? words[0][0] and !word_hashset.member? words[0] #checks if nextWord is a symboled word
              @sms_skills = @sms_skills + words[0] + " "
              words.slice!(0)
            end
            @sms_skills.chop!
          when "@"
            @sms_location = nextWord + " "
            words.slice!(0)
            while !words.empty? and !symbol_hashset.member? words[0][0] and !word_hashset.member? words[0] #checks if nextWord is a symboled word
              @sms_location = @sms_location + words[0] + " "
              words.slice!(0)
            end
            @sms_location.chop!
          when "#"
            @sms_summary = nextWord + " "
            words.slice!(0)
            while !words.empty? and !symbol_hashset.member? words[0][0] and !word_hashset.member? words[0] #checks if nextWord is a symboled word or key word
              @sms_summary = @sms_summary + words[0] + " "
              words.slice!(0)
            end
            @sms_summary.chop!
          when "$"
            @sms_price = nextWord + " "
            words.slice!(0)
            while !words.empty? and !symbol_hashset.member? words[0][0] and !word_hashset.member? words[0]#checks if nextWord is a symboled word or key word
              @sms_price = @sms_price + words[0] + " "
              words.slice!(0)
            end
            @sms_price.chop!
        end
      else
        if word_hashset.member? nextWord
          case nextWord.downcase
            when "limit"
              words.slice!(0)
              nextWord = words[0]
              if !is_num?(nextWord)
                sms_error("LIMIT must be followed by a integer number")
                @sms_error = true
                break
              end
              @sms_limit = nextWord.to_i
          end
        else
          words.slice!(0)
        end
      end
    end
    return action
  end

  def sms_authenticate
    if @client == nil
      account_sid = 'ACafb3d0d7820d6b39613ffdc47d5f074f'#'AC7bec7276c109417979adfc442a675fc9'
      auth_token = '71aedf3c912ea6f64b719d671adea8b3'#'6ca5a284c956fc0a444ba453ca63508b'
      @client = Twilio::REST::Client.new(account_sid, auth_token)
    end
  end

  def sms_error(error_string)
    sms_authenticate
    @client.account.sms.messages.create(:from => params[:To], :to => params[:From], :body => error_string)
  end

  def sms_send(string)
    sms_authenticate
    @client.account.sms.messages.create(:from => params[:To], :to => params[:From], :body => string)
  end

  def sms_get(offset)
    location = @sms_location
    skills = @sms_skills
    amountOfTexts = @sms_limit

    if @offset
      amountOfTexts = @problem_text[1]
    end

    sms_authenticate

    amountOfTexts.times do |i|
      body = ""
      if skills and location
        problems = Problem.where(:skills => skills, :location => location).order("created_at DESC").limit(5).offset(offset)
      elsif skills
        problems = Problem.where(:skills => skills).order("created_at DESC").limit(5).offset(offset)
      elsif location
        problems = Problem.where(:location => location).order("created_at DESC").limit(5).offset(offset)
      else
        problems = Problem.find(:all, :order => "created_at DESC").limit(5).offset(offset)
      end
      problems.each do |problem|
            tmpbody = body +  problem.to_s
            if tmpbody.length <= TEXTLENGTH
              body = tmpbody
              offset +=1
            else
              break
            end
      end
      if body == ""
        body = "There are no more additional problems for "
        location ? body += "Location: #{location} " : false
        skills ? body += "Skills: #{skills} " : false
        sms_send(body)
        break
      else
        sms_send(body)
      end
    end
    session["offset"] = offset
  end

  def sms_detail
    problem_id = @problem_text[1].to_i
    problem = Problem.find(problem_id)

    sms_authenticate

    if !problem.nil?
      problem_details = problem.more_detail
      current = 0
      (problem_details.length/(TEXTLENGTH.to_f)).ceil.times do |i|
        sms_send(problem_details.slice(current, current + TEXTLENGTH))
        current += TEXTLENGTH
      end
    else
      sms_error("Sorry, that problem id does not exist")
    end
  end

  # sms support for problem creation
  def sms_create
    success_msg = "You have successfully posted your problem. We will notify you of any updates as soon as possible. Thank you for using Emplify!"
    failure_msg = "Sorry, something seems to have gone wrong. We can't post your problem at this time."
    summary = @sms_summary
    location = @sms_location
    skills = @sms_skills

    @problem = Problem.new(:location => location, :summary => summary, :skills => skills)
    add_problem_to_user_sms

    if save_problem_sms
      body = success_msg
    else
      body = failure_msg
    end

    sms_authenticate
    sms_send(body)
  end

  def add_problem_to_user_sms
    @user = User.find_by_phone_number(params[:From])
    if @user.nil?
      @user = User.new(:phone_number => params[:From])
    end
    @user.problems << @problem
  end

  def new
    @all_skills = Skill.find(:all)
    render 'problems/new'
  end

  def save_problem
    if @user.save!
      flash[:notice] = 'You have successfully created a problem!'
    else
      flash[:error] = 'There was a problem with creating the problem.'
    end
    redirect_to problems_path
  end

  def save_problem_sms
    if @user.save
      return true
    else
      return false
    end
  end

  def show
    id = params[:id]
    @problem = Problem.find(id)
    @user = @problem.user
    @verifiedUser = false
    account = session[:account]
    if account != nil
      if account.user.phone_number == @user.phone_number
        @verifiedUser = true
      end
    end
  end

  def edit
    @problem = Problem.find(params[:id])
    @user = @problem.user
    account = session[:account]
    if account != nil
      if account.user.phone_number == @user.phone_number
        @verifiedUser = true
      end
    end
    if @verifiedUser
      @all_skills = Skill.find(:all)
      @curr_skills = @problem.skills
    else
      flash[:notice] = 'You do not have permission to edit this problem.'
      redirect_to problems_path
    end
  end

  def update
    @problem = Problem.find(params[:id])
    @user = @problem.user
    account = session[:account]
    if account != nil
      if account.user.phone_number == @user.phone_number
        @verifiedUser = true
      end
    end
    if @verifiedUser
      @problem.update_attributes!(params[:problem].merge!({:skills => params[:skills]}))
      flash[:notice] = "#{@problem.summary} was successfully updated."
      redirect_to problem_path(@problem)
    else
      flash[:notice] = 'You do not have permission to edit this problem.'
      redirect_to problems_path
    end
  end

  #Expecting the input to look like: "accept #[problem id] ![password]"
  def sms_accept_problem
    problem_id = @problem_text[1]
    password = @problem_text[2]
    provider_user = User.find_by_phone_number(normalize_phone(params[:From]))
    @provider_acc = provider_user.account
    if provider_acc.nil?
      body = "Sorry, there is no account associated with your phone number"
    elsif provider_acc.password == password
      #mark it as done
      problem = Problem.find(problem_id)
      if problem.nil?
        body = "Sorry, there is no problem that matches ID #{problem_id}"
      else
        requester = problem.user
        body = "You have accepted problem ##{problem_id}. Please contact #{requester.name} at #{requester.phone_number} as soon as possible."
      end
      #send a notification to the requester saying that a provider will be contacting shortly
      requester_msg = "Your #{problem.summary} problem has been accepted by #{provider.name}, whom you can contact at #{provider.phone_number}."
      @client.account.sms.messages.create(:from => params[:To], :to => requester.phone_number, :body => requester_msg)
    else
      body = "Sorry, incorrect password"
    end
    #send a reply back to the provider with the required information
    send_sms(body)
  end

  def normalize_phone phone_number
    return phone_number.gsub('(','').gsub(')','').gsub('-','').gsub('+','')
  end

  def destroy
    @problem = Problem.find(params[:id])
    @user = @problem.user
    account = session[:account]
    if account != nil
      if account.user.phone_number == @user.phone_number
        @verifiedUser = true
      end
    end
    if @verifiedUser
      @problem = Problem.find(params[:id])
      @problem.destroy
      flash[:notice] = "Problem '#{@problem.summary}' deleted."
      redirect_to problems_path
    else
      flash[:notice] = 'You do not have permission to delete this problem.'
      redirect_to problems_path
    end
  end

  def is_num?(str)
    Integer(str)
    rescue ArgumentError
      false
    else
      true
  end

end
