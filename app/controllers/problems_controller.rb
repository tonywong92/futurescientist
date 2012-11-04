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
    @curr_skills = Problem.select("*").group("skills")
    @curr_addresses = Problem.select("*").group("location")
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
  
  # sms support for problem creation
  def sms_create
    success_msg = "You have successfully posted your problem. We will notify you of any updates as soon as possible. Thank you for using Emplify!"
    failure_msg = "Sorry, something seems to have gone wrong. We can't post your problem at this time."
    
    problem_text = params[:Body].split
    
    
    twiml = Twilio::TwiML::Response.new do |r|
      if success
        r.Sms success_msg
      else
        r.Sms failure_msg
      end
    end
    twiml.text
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
