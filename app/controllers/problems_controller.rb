class ProblemsController < ApplicationController

  def index
    @problems = Problem.find(
	    :all,
	    :order => "id ASC")
  end

  def new
    # default: render 'new' template
  end

end
