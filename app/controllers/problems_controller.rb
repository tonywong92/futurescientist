class ProblemsController < ApplicationController

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
    @problem_text = params[:Body].split
    case @problem_text[0]
      when /^ADD$/
        sms_create
    end
  end

  # sms support for problem creation
  def sms_create
    success_msg = "You have successfully posted your problem. We will notify you of any updates as soon as possible. Thank you for using Emplify!"
    failure_msg = "Sorry, something seems to have gone wrong. We can't post your problem at this time."
    summary = @problem_text[1]
    location = @problem_text[2]
    skills = @problem_text[3]

    @problem = Problem.new(:location => location, :summary => summary, :skills => skills)
    add_problem_to_user_sms

    if save_problem_sms
      body = success_msg
    else
      body = failure_msg
    end

    account_sid = 'AC65e34f3e42326c21b8d1c915c1817f7e'
    auth_token = '0814d38b55c49cfc462463d643328287'
    @client = Twilio::REST::Client.new account_sid, auth_token

    puts 'params[:To]: ', params[:To]
    puts 'params[:From]: ', params[:From]

    @client.account.sms.messages.create(:from => params[:From], :to => params[:To], :body => body)
    redirect_to problems_path
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

=begin
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
=end
end
