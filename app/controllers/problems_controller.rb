class ProblemsController < ApplicationController

  def index
    @problems = Problem.find(
	    :all,
	    :order => "id ASC")
  end

  def create
    new
  end

  def new
    @all_skills = Skill.find(:all)
    if request.post?
      @problem = Problem.new(:location => params[:user][:location], :summary => params[:problem][:summary], :description => params[:problem][:description], :skills => params[:problem][:skills])

      @user = User.find_by_phone_number(params[:user][:phone_number])
      if @user.nil?
        @user = User.new
        @user.attributes = params[:user]
      end
      @user.problems << @problem
      save_problem
      return
    end
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

  end

  def destroy

  end

end
