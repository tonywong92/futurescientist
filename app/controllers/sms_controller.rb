class SmsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def uninitialize_sms
    @sms_location = nil
    @sms_skills = nil
    @sms_summary = nil
    @sms_wage = nil
    @sms_limit = nil
    @client = nil
    @sms_error = false
  end

  #sms superfunction for receiving texts
  def receive_sms
    uninitialize_sms
    body = params[:Body]
    @problem_text = body.split
    action = sms_parsing(body).downcase
    if !@sms_error
      case action
        when /^add$/,/^insert$/
          sms_create
        when /^accept$/
          sms_accept_problem
        when /^get$/
          @offset = false
          sms_get(0)
        when /^edit$/
          sms_edit
        when /^delete$/, /^destroy$/
          sms_delete
        when /^next$/
          offset = session["offset"]
          if offset == nil
            sms_error("Sorry, there is no saved session right now. Please first text \"GET\" with @location !skill %number of texts you want to allow.")
          else
            @offset = true
            sms_get(offset)
          end
        when /^detail$/, /^details$/, /^describe$/
          sms_detail
        when /^account$/
          forgot_acc
        when /^change$/
          sms_change_password
        when /^password$/
          forgot_password
        else
          if is_num?(action)
            puts "SMS CONFIRMATION IS CALLED"
            puts "SMS CONFIRMATION IS CALLED"
            puts "SMS CONFIRMATION IS CALLED"
            puts "SMS CONFIRMATION IS CALLED"
            puts "SMS CONFIRMATION IS CALLED"
            session[:received_confirmation] = action
            sms_confirm_acc
          end
      end
    end
    render :nothing => true
  end

  #call this to do all the logic to parse the incomming text
  #returns the action that the text wants
  #sets @sms_location if there's a "@location"
  #sets @sms_skills if there's a !skills
  #sets @sms_summary if there's a #summary
  #sets @sms_wage if there's a $wage
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
            while !words.empty? and !symbol_hashset.member? words[0][0] and !word_hashset.member? words[0].downcase #checks if nextWord is a symboled word
              @sms_skills = @sms_skills + words[0] + " "
              words.slice!(0)
            end
            @sms_skills.chop!
          when "@"
            @sms_location = nextWord + " "
            words.slice!(0)
            while !words.empty? and !symbol_hashset.member? words[0][0] and !word_hashset.member? words[0].downcase #checks if nextWord is a symboled word
              @sms_location = @sms_location + words[0] + " "
              words.slice!(0)
            end
            @sms_location.chop!
          when "#"
            @sms_summary = nextWord + " "
            words.slice!(0)
            while !words.empty? and !symbol_hashset.member? words[0][0] and !word_hashset.member? words[0].downcase #checks if nextWord is a symboled word or key word
              @sms_summary = @sms_summary + words[0] + " "
              words.slice!(0)
            end
            @sms_summary.chop!
          when "$"
            @sms_wage = nextWord.to_f
            words.slice!(0)
        end
      else
        if word_hashset.member? nextWord.downcase
          case nextWord.downcase
            when "limit"
              words.slice!(0)
              nextWord = words[0]
              if nextWord == nil or !is_num?(nextWord)
                sms_error("LIMIT must be followed by a integer number")
                @sms_error = true
                break
              end
              @sms_limit = nextWord.to_i
              words.slice!(0)
          end
        else
          words.slice!(0)
        end
      end
    end
    if !@sms_location.nil?
      @sms_location = @sms_location.downcase.strip
    end
    if !@sms_skills.nil?
      @sms_skills = @sms_skills.downcase.strip
    end
    return action
  end

  def sms_get(offset)
    location = @sms_location
    skills = @sms_skills
    amountOfTexts = @sms_limit

    if @offset
      amountOfTexts = @problem_text[1].to_i
      location = session["location"]
      skills = session["skills"]
    end

    amountOfTexts.times do |i|
      body = ""
      if !skills.nil? and !location.nil?
        problems = Problem.where(:skills => skills, :location => location).order("created_at DESC").limit(5).offset(offset)
      elsif !skills.nil?
        problems = Problem.where(:skills => skills).order("created_at DESC").limit(5).offset(offset)
      elsif !location.nil?
        problems = Problem.where(:location => location).order("created_at DESC").limit(5).offset(offset)
      else
        problems = Problem.find(:all, :order => "created_at DESC", :limit => 5, :offset => offset)
      end
      problems.each do |problem|
	    tmpbody = body +  problem.to_s + " "
	    if tmpbody.length <= TEXTLENGTH
	      body = tmpbody
	      offset +=1
	    else
	      break
	    end
      end
      body = body.strip
      if body == ""
        body = "There are no more additional problems"
        body += (location || skills) ? " for" : "."
        body += (location) ? " Location: #{location}" : ""
        body += (skills) ? " Skills: #{skills}." : "."
        sms_send(body)
        break
      else
        sms_send(body)
      end
    end
    session["offset"] = offset
    session["location"] = location
    session["skills"] = skills
  end

  def sms_detail
    problem_id = @problem_text[1]
    begin
      problem = Problem.find(problem_id)
      problem_details = problem.more_detail + " "
      current = 0
      (problem_details.length/(TEXTLENGTH.to_f)).ceil.times do |i|
        sms_send(problem_details.slice(current, current + TEXTLENGTH))
        current += TEXTLENGTH
      end
    rescue ActiveRecord::RecordNotFound
      sms_error("Sorry, that problem id does not exist")
    end
  end

  # sms support for problem creation
  def sms_create
    summary = @sms_summary
    location = @sms_location
    skills = @sms_skills
    wage = @sms_wage

    @problem = Problem.new(:location => location, :summary => summary, :skills => skills, :wage => wage)
    add_problem_to_user_sms

    sms_authenticate
    if sms_save_problem
      sms_send("You have successfully posted your problem(id: #{@problem.id}). We will notify you of any updates as soon as possible. Thank you for using Emplify!")
    else
      @problem.errors.full_messages.each do |error|
          sms_error(error)
      end
    end
  end

  def add_problem_to_user_sms
    @user = User.find_by_phone_number(params[:From])
    if @user.nil?
      @user = User.new(:phone_number => params[:From])
    end
    @user.problems << @problem
  end

  def sms_save_problem
    if @user.save
      return true
    else
      return false
    end
  end

  def sms_edit
    sms_authenticate
    problem_id = @problem_text[1]
    phone_number = params[:From]
    begin
      problem = Problem.find(problem_id)
      if problem.user.phone_number == phone_number
        summary = @sms_summary || problem.summary
        location = @sms_location || problem.location
        skills = @sms_skills || problem.skills
        wage = @sms_wage || problem.wage

        if problem.update_attributes(:summary => summary, :location => location, :skills => skills, :wage => wage)
          sms_send("Your problem has successfully been edited.")
        else
          problem.errors.full_messages.each do |error|
             sms_error(error)
          end
        end
      else
        sms_error("Sorry. You do not have permission to edit this problem as this is not the phone number that created this problem.")
      end
    rescue ActiveRecord::RecordNotFound
      sms_error("Sorry, that problem id does not exist.")
    end
  end

  def sms_delete
    sms_authenticate
    problem_id = @problem_text[1]
    phone_number = params[:From]
    begin
      problem = Problem.find(problem_id)
      if problem.user.phone_number == phone_number
          problem.destroy
          sms_send("Your problem has successfully been deleted.")
      else
          sms_error("Sorry. You do not have permission to edit this problem as this is not the phone number that created this problem.")
      end
    rescue ActiveRecord::RecordNotFound
      sms_error("Sorry, that problem id does not exist.")
    end
  end

  #Expecting the input to look like: "accept [problem id] [password]"
  def sms_accept_problem
    problem_id = @problem_text[1]
    password = @problem_text[2]
    provider_user = User.find_by_phone_number(normalize_phone(params[:From]))
    if !provider_user.nil?
      provider_acc = provider_user.account
    end
    if provider_acc.nil?
      sms_error("There is no verified account for #{params[:From]}. Please reply in the following format: 'Accept [problem ID] [yourPassword]'")
    elsif provider_acc.password == Account.to_hmac(password)
      problem = Problem.find_by_id(problem_id)
      if problem.nil?
        sms_error("Sorry, there is no problem that matches ID #{problem_id}. Please reply in the following format: 'Accept [problem ID] [your_password]'")
      else
        problem.archived = true
        problem.save
        requester = problem.user
        sms_send("You have accepted problem ##{problem_id}. Please contact your requester at #{requester.phone_number} as soon as possible.")
        #send a notification to the requester saying that a provider will be contacting shortly
        requester_msg = "Your #{problem.summary} problem has been accepted by #{provider_acc.account_name}, whom you can contact at #{provider_user.phone_number}."
        sms_authenticate
        @client.account.sms.messages.create(:from => params[:To], :to => requester.phone_number, :body => requester_msg)
      end
    else
      sms_error("Sorry, incorrect password. Please reply in the following format: 'Accept [problem ID] [your_password]'")
    end
  end

  def sms_confirm_acc
    acc = Account.find(@problem_text[0])
    acc_name = @problem_text[1]
    if !acc.nil? and acc_name == acc.account_name
      acc.verified = true
      acc.save
      sms_send("We have received your confirmation. Thank you for creating an account with Emplify!")
    else
      sms_error("Sorry, the reply we received doesn't seem to match the information we sent. Please check your confirmation number and try again.")
    end
  end

  def normalize_phone phone_number
    if phone_number != nil and !phone_number.strip.empty?
      number = phone_number.gsub('(','').gsub(')','').gsub('-','').gsub('+','')
      if number.length == 11
        number.slice!(0)
      end
      return '+1' + number
    else
      return false
    end
  end

  def forgot_password
    provider_user = User.find_by_phone_number(normalize_phone(params[:From]))
    if !provider_user.nil?
      provider_acc = provider_user.account
    end
    if provider_acc.nil?
      sms_error("There is no account associated with this number.")
    else
      session[:change_account] = provider_acc.id
      sms_send("Please text back 'change [new password]' Please keep in mind that your password must be at least 6 characters with 1 capital letter.")
    end
  end

  def sms_change_password
    password = @problem_text[1]
    id = session[:change_account]
    if id.nil?
      sms_error("Sorry, please send another request 'password' to this number.")
    else
      if (password =~ /[A-Z]{1}/) == nil #currently manually doing this until figure out validate_password_for_update in account.rb
      	sms_error("Password needs to have at least 1 capital letter")
      else
        account = Account.find(id)
      	if account.update_attributes(:password => password)
        	 sms_send("Your password has successfully been changed.")
      	else
          	account.errors.full_messages.each do |error|
             		sms_error(error)
          	end
      	end
      end
    end
  end

  def forgot_acc
    provider_user = User.find_by_phone_number(normalize_phone(params[:From]))
    if !provider_user.nil?
      provider_acc = provider_user.account
    end
    if provider_acc.nil?
      sms_error("There is no account associated with this number.")
    else
      sms_send("Your account name is #{provider_acc.account_name}")
    end
  end
end
