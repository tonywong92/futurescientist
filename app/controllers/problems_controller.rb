require 'set'

class ProblemsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  TEXTLENGTH = 160

  def index
#    @sessionSkills = []
    @sessionAddresses = []
#    skills = params[:skills] || session[:skills] || {}
    addresses = params[:address] || session[:address] || {}
    if addresses == {}
      addresses = ["All"]
    end
#    if skills == {}
#      skills = ["All"]
#    end
#    if params[:skills] != session[:skills]
#      session[:skills] = skills
#      session[:address] = addresses
#      flash.keep
#      redirect_to :skills => skills, :address => addresses and return
#    end
    if params[:address] != session[:address]
#      session[:skills] = skills
      session[:address] = addresses
      flash.keep
      redirect_to :address => addresses and return #:skills => skills, supposed to be same as line above
    end
#    @sessionSkills = skills
    @sessionAddresses = addresses
#    if skills.include? "All" and addresses.include? "All"
#    @problems = Problem.where(:archived => false).order("created_at DESC")
#    elsif skills.include? "All"
#  @problems = Problem.where(:location => addresses, :archived => false).order("created_at DESC")
    if addresses.include? "All" #change to elsif if skills are added back in
#      @problems = Problem.where(:skills => skills, :archived => false).order("created_at DESC")
      @problems = Problem.where(:archived => false).order("created_at DESC")
    else
#      @problems = Problem.where(:skills => skills, :location => addresses, :archived => false).order("created_at DESC")
      @problems = Problem.where(:location => addresses, :archived => false).order("created_at DESC")
    end
#    @curr_skills = Problem.select(:skills).uniq
    @curr_addresses = Problem.select(:location).uniq
  end

  def new
    if !session[:account].nil?
      acc = Account.find_by_id(session[:account])
      @user_name = acc.name
      @user_phone = acc.phone_number
      @user_location = acc.location
    else
      @user_name = ""
      @user_phone = ""
      @user_location = ""
    end
    #@all_skills = Skill.find(:all)
    render 'problems/new'
  end

  def create
    @problem = Problem.new(:wage => params[:problem][:wage], :location => params[:problem][:location], :summary => params[:problem][:summary], :description => params[:problem][:description]) #, :skills => params[:skills]

    @acc = Account.find_by_phone_number(normalize_phone(params[:account][:phone_number]))
    if @acc.nil?
      @acc = Account.new
      @acc.attributes = params[:account]
    end
    @acc.problems << @problem
    save_problem
    return
  end

  def save_problem
    if @acc.save
      flash[:notice] = 'You have successfully created a problem!'
      redirect_to problems_path
    else
      flash[:error] = 'There was a problem with creating the problem.'
      if !@acc.errors.empty?
        flash[:acc_errors] = @acc.errors.full_messages
      end
      if !@problem.errors.empty?
        flash[:problem_errors] = @problem.errors.full_messages
      end
      redirect_to new_problem_path
    end
  end

  def show
    @id = params[:id]
    @problem = Problem.find_by_id(@id)
    @acc = @problem.account
    @verifiedUser = false
    @account = Account.find_by_id(session[:account])
    if @account != nil
#      @qualified_provider = @account.verified_skills.include?(@problem.skills)
      @is_admin = @account.admin
      if @account.phone_number == @acc.phone_number
        @verifiedUser = true
      end
      return
    else
      flash[:notice] = "You are not yet logged in. Please log in first or create an account before viewing any problems."
      redirect_to problems_path
    end
  end

  def accept_problem
    provider_id = params[:provider_id]
    if provider_id.to_s == session[:account].to_s
      problem_id = params[:problem_id]
      problem = Problem.find_by_id(problem_id)
      requester = problem.account
      provider = Account.find_by_id(provider_id)
      provider.problems << problem
      if provider.save
        problem.archived = true
        problem.save
        requester = problem.account
        begin
          sms_send(provider.phone_number, "You have accepted problem ##{problem_id}. Please contact your requester at #{requester.phone_number} as soon as possible.")
          #send a notification to the requester saying that a provider will be contacting shortly
          requester_msg = "Your #{problem.summary} problem has been accepted by #{provider.account_name}, whom you can contact at #{provider.phone_number}."
          sms_send(requester.phone_number, requester_msg)
        rescue Twilio::REST::RequestError
          flash[:notice] = 'We seem to be having difficulties sending a text to your phone number. Please try again later'
          redirect_to problems_path
          return
        end
      else
        flash[:notice] = 'Something went wrong. Please try again at a later time.'
        redirect_to problems_path
        return
      end
    else
      flash[:notice] = 'You are not currently logged in. Please log in before accepting problems.'
      redirect_to problems_path
      return
    end
    flash[:notice] = "You have sucessfully accepted the problem: #{problem.summary}. Please follow the instructions on the text you received."
    redirect_to problems_path
  end

  def edit
    @problem = Problem.find(params[:id])
    @acc = @problem.account
    account = Account.find_by_id(session[:account])
    if account != nil
      @is_admin = account.admin
      if account.phone_number == @acc.phone_number
        @verifiedUser = true
      end
    end
    if @verifiedUser or @is_admin
#      @all_skills = Skill.find(:all)
#      @curr_skills = @problem.skills
    else
      flash[:notice] = 'You do not have permission to edit this problem.'
      redirect_to problems_path
    end
  end

  def update
    @problem = Problem.find(params[:id])
    @acc = @problem.account
    account = Account.find_by_id(session[:account])
    if account != nil
      @is_admin = account.admin
      if account.phone_number == @acc.phone_number
        @verifiedUser = true
      end
    end
    if @verifiedUser or @is_admin
      @problem.update_attributes!(params[:problem].merge!({:skills => params[:skills]}))
      flash[:notice] = "#{@problem.summary} was successfully updated."
      redirect_to problem_path(@problem)
    else
      flash[:notice] = 'You do not have permission to edit this problem.'
      redirect_to problems_path
    end
  end

  def destroy
    @problem = Problem.find(params[:id])
    @acc = @problem.account
    account = Account.find_by_id(session[:account])
    if account != nil
      @is_admin = account.admin
      if account.phone_number == @acc.phone_number
        @verifiedUser = true
      end
    end
    if @verifiedUser or @is_admin
      @problem = Problem.find(params[:id])
      @problem.destroy
      flash[:notice] = "Problem '#{@problem.summary}' deleted."
      redirect_to problems_path
    else
      flash[:notice] = 'You do not have permission to delete this problem.'
      redirect_to problems_path
    end
  end

  def instructions
    #TODO: allow this to be changed by an admin, so it's not static instructions, and instructions can constantly change.
    @TWILIO = TWILIO
    render '/problems/instructions'
  end
end
