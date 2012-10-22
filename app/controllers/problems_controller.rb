class ProblemsController < ApplicationController

  def index
    @problems = Problem.find(
	:all,
	:order => "id ASC")
end

end
