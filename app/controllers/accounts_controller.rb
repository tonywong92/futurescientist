require 'rubygems'
require 'openssl'
require 'base64'
require 'cgi'
require 'hmac-sha1'

class AccountsController < ApplicationController

  # Loads the account creation form
  def new
    @all_skills = Skill.find(:all)
  end

  # Creates a new account after user submits the account creation form. Note: we treat phone number specially because that field is associated with a user, not an account, and therefore is not subject to the account model validations
  def create
    @all_skills = Skill.find(:all)
    phone_number = normalize_phone(params[:user][:phone_number].strip)
    @user = User.new(params[:user])
    @account = Account.new(params[:account])
    if phone_number
      @user.phone_number = phone_number
      if params[:account][:password].empty?
        flash[:notice] = 'Password is a required field'
      end
      if params[:Admin] == '1'
        @account.admin = true
        @account.verified_skills = params[:skills]
      else
        @account.admin = false
        @account.skills = params[:skills]
        @sv = SkillVerification.new
        @sv.account = @account
        @sv.save!
      end
=begin
      begin
        sms_send(@user.phone_number, "You have successfully created an account! Please reply with the number: #{@account.id}")
      rescue Twilio::REST::RequestError
        
      end
=end
      @user.account = @account
      save_account
      return
    else
      flash[:notice] = 'Phone Number is a required field'
      redirect_to new_account_path
    end
  end

  def save_account
    if @user.save and @account.save
      if session[:account].nil?
        session[:account] = @account.id
      end
      flash[:notice] = 'You have successfully created an account'
      redirect_to problems_path
    else
      flash[:error] = 'There was a problem with creating your account'
      if !@user.errors.empty?
        flash[:user_errors] = @user.errors.full_messages
      end
      if !@account.errors.empty?
        flash[:account_errors] = @account.errors.full_messages
      end
      @all_skills = Skill.find(:all)
      redirect_to new_account_path
    end
  end

  def show
    @user = Account.find_by_id(session[:account]).user
  end

  def skills_verification
    # List of Accounts that have skills that are unverified.
    @accounts_list = []
    SkillVerification.all.each do |a|
      @accounts_list << a.account_id
    end

    @accounts_list.each do |a|
      account = Account.find_by_id(a)
      account.skills.delete_if do |skill|
        puts skill
        key = (a.to_s() + "_" + skill).to_sym
        if params[key] == 'true'
          if account.verified_skills.empty?
            account.verified_skills = [skill]
          else
            account.verified_skills << skill
          end
          true
        else
          false
        end
      end
      account.save!
      if account.skills.empty?
        SkillVerification.destroy(SkillVerification.find_by_account_id(a).id)
        @accounts_list.delete(a)
      end
    end

    render '/accounts/skills_verification'
  end

  def login_form
    render '/accounts/login_form'
  end

  def login
    @account = Account.find_by_account_name(params[:account][:account_name])
    if @account.nil?
      flash[:error] = 'No such account exists'
      render '/accounts/login_form'
    else
      validate_password
    end
  end

  def logout
    reset_session
    flash[:notice] = "You have successfully logged out"
    redirect_to problems_path
  end

  def validate_password
    if @account.password == Account.to_hmac(params[:account][:password])
      session[:account] = @account.id
      flash[:notice] = "Welcome, #{@account.account_name}"
      redirect_to problems_path
    else
      flash[:error] = 'Your password is incorrect'
      render '/accounts/login_form'
    end
  end

  def edit
    @all_skills = Skill.find(:all)
  end

  def update
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to problems_path
    elsif params[:type] == 'edit_email'
      @account.update_attributes!(:email => params[:email][:address])
      flash[:notice] = "Email changed!"
      redirect_to edit_account_path(@account.id)
    elsif params[:type] == 'edit_password'
      changepass
    elsif params[:type] == 'edit_phone'
      changenumber
    elsif params[:type] == 'edit_location'
      changelocation
    elsif params[:type] == 'edit_skills'
      changeskills
    end
  end

  def changepass
    @account = Account.find_by_id(session[:account])
    if @account.nil?
       flash[:notice] = "You are not logged in"
       redirect_to problems_path
    elsif Account.to_hmac(params[:password][:current]) != @account.password
       flash[:notice] = "Password incorrect"
       redirect_to edit_account_path(@account.id)
    elsif params[:password_new][:new] == params[:reenter][:pass]
      @account.update_attributes!(:password => params[:password_new][:new])
      flash[:notice] = "Password changed"
      redirect_to edit_account_path(@account.id)
    else
      flash[:notice] = "The new password you entered doesn't match"
      redirect_to edit_account_path(@account.id)
    end
  end

  def changenumber
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to problems_path
    else
      phoneNum = params[:phone][:number]
      phoneNum = normalize_phone phoneNum
      @account.user.update_attributes!(:phone_number => phoneNum)
      flash[:notice] = "Phone number changed"
      redirect_to edit_account_path(@account.id)
    end
  end

  def changelocation
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to problems_path
    else
      newLocation = params[:location][:name]
      @account.user.update_attributes!(:location => newLocation)
      flash[:notice] = "Location changed"
      redirect_to edit_account_path(@account.id)
    end
  end

  def changeskills
    @all_skills = Skill.find(:all)
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to problems_path
    elsif @account.admin
      @account.update_attributes!(:verified_skills => params[:skills])
      flash[:notice] = "Skills updated"
      redirect_to edit_account_path(@account.id)
    else
      @account.update_attributes!(:skills => params[:skills])
      flash[:notice] = "Skills to be verified"
      redirect_to edit_account_path(@account.id)
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

  def sms_authenticate
    if @client == nil
      account_sid = 'AC7bec7276c109417979adfc442a675fc9'
      auth_token = '6ca5a284c956fc0a444ba453ca63508b'
      @client = Twilio::REST::Client.new(account_sid, auth_token)
    end
  end

  def sms_error(to, error_string)
    sms_authenticate
    @client.account.sms.messages.create(:from => '+16502674928', :to => to, :body => error_string)
  end

  def sms_send(to, string)
    sms_authenticate
    @client.account.sms.messages.create(:from => '+16502674928', :to => to, :body => string)
  end

end
