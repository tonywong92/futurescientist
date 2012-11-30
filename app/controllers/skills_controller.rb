require 'rubygems'
require 'openssl'
require 'base64'
require 'cgi'
require 'hmac-sha1'

class SkillsController < ApplicationController

  def new    
  end

  def create
  	@skills = Skill.create!(params[:skills])
    flash[:notice] = "#{@skills.skill_name} was successfully created."
    redirect_to new_skill_path
  end

end