class ProblemsController < ApplicationController

  def index
    @problems = Problem.find(
	    	  :all,
	      	  :order => "created_at DESC")
  end

  def create
    @problem = Problem.new(:location => params[:user][:location], :summary => params[:problem][:summary], :description => params[:problem][:description], :skills => params[:skills])

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
    problem_text = params[:Body].split
    case problem_text[0]
      when /^ADD$/
        sms_create problem_text
    end
  end
  
  # sms support for problem creation
  def sms_create problem_text
    success_msg = "You have successfully posted your problem. We will notify you of any updates as soon as possible. Thank you for using Emplify!"
    failure_msg = "Sorry, something seems to have gone wrong. We can't post your problem at this time."
    summary = problem_text[1]
    location = problem_text[2]
    skills = problem_text[3]
    
    @problem = Problem.new(:location => location, :summary => summary, :skills => skills)
    add_problem_to_user_sms
    twiml = Twilio::TwiML::Response.new do |r|
      if save_problem_sms
        r.Sms success_msg
      else
        r.Sms failure_msg
      end
    end
    twiml.text
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
  end

  def edit
   #TODO: NEED TO ADD LOGIC about how to verify person editing.
    @problem = Problem.find(params[:id])
    @all_skills = Skill.find(:all)
    @user = @problem.user
  end

  def update
    #TODO: NEED TO ADD LOGIC FOR updating user.
    @problem = Problem.find(params[:id])
    @problem.update_attributes!(params[:problem])
    flash[:notice] = "#{@problem.summary} was successfully updated."
    redirect_to problem_path(@problem)
  end

  def destroy
    #TODO: NEED TO ADD LOGIC about how to verify person editing.
    @problem = Problem.find(params[:id])
    @problem.destroy
    flash[:notice] = "Problem '#{@problem.summary}' deleted."
    redirect_to problems_path
  end

end
