class ProblemsController < ApplicationController

  def index
    @problems = Problem.find(
	:all,
	:order => "id ASC")
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
