require 'rubygems'
require 'openssl'
require 'base64'
require 'cgi'
require 'hmac-sha1'

class AccountsController < ApplicationController

  def new
    @all_skills = Skill.find(:all)
  end

  def create
    @all_skills = Skill.find(:all)
    @user = User.new(params[:user])
    @account = Account.new(params[:account])
    hmac = HMAC::SHA1.new('1234')
    hmac.update(params[:account][:password])
    @account.password = hmac.to_s
    if @user.phone_number != nil and !@user.phone_number.empty?
      @user.phone_number = normalize_phone(@user.phone_number)
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
    @user.account = @account
    if @user.phone_number != nil and !@user.phone_number.empty?
      @user.phone_number = normalize_phone(@user.phone_number)
    end
    save_account
    # TODO: user can receive a text and confirm it through text (stored in a session) before an account is actually created. make sure it fails nicely as wel
=begin
    begin
      sms_send(@user.phone_number, "You have successfully created an account with the number #{@user.phone_number}. Congratulations!")
    rescue Twilio::REST::RequestError

    end
=end
    return
  end

  def save_account
    if @account.save and @user.save
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
      redirect_to '/accounts/new'
    end
  end

  def show
    @user = Account.find_by_id(session[:account]).user
    render '/accounts/show'
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
    hmac = HMAC::SHA1.new('1234')
    hmac.update(params[:account][:password])
    if @account.password == hmac.to_s
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
    render '/accounts/edit'
  end

  def update
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to '/accounts/edit'
    elsif
      @account.update_attributes!(:email => params[:email][:address])
      flash[:notice] = "Email changed!"
      redirect_to '/accounts/edit'
    end
  end

  def changepass
    @account = Account.find_by_id(session[:account])
    hmac = HMAC::SHA1.new('1234')
    hmac.update(params[:password][:current])
    if @account.nil?
       flash[:notice] = "You are not logged in"
       redirect_to '/accounts/edit'
    elsif hmac.to_s != @account.password
       flash[:notice] = "Password incorrect"
       redirect_to '/accounts/edit'
    elsif params[:password_new][:new] == params[:reenter][:pass]
      hmac.update(params[:password_new][:new])
      @account.update_attributes!(:password => hmac.to_s)
      flash[:notice] = "Password changed"
      redirect_to '/accounts/edit'
    else
      flash[:notice] = "The new password you entered doesn't match"
      redirect_to '/accounts/edit'
    end
  end

  def changenumber
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to '/accounts/edit'
    else
      phoneNum = params[:phone][:number]
      phoneNum = normalize_phone phoneNum
      @account.user.update_attributes!(:phone_number => phoneNum)
      flash[:notice] = "Phone number changed"
      redirect_to '/accounts/edit'
    end
  end

  def changelocation
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to '/accounts/edit'
    else
      newLocation = params[:location][:name]
      @account.user.update_attributes!(:location => newLocation)
      flash[:notice] = "Location changed"
      redirect_to '/accounts/edit'
    end
  end

  def changeskills
    @all_skills = Skill.find(:all)
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to '/accounts/edit'
    elsif @account.admin == 't'
      @account.update_attributes!(:verified_skills => params[:skills])
      flash[:noticed] = "Skills updated"
      redirect_to '/accounts/edit'
    else
      @account.update_attributes!(:skills => params[:skills])
      flash[:notice] = "Skills to be verified"
      redirect_to '/accounts/edit'
    end
  end

  def normalize_phone phone_number
    number = phone_number.gsub('(','').gsub(')','').gsub('-','').gsub('+','')
    if number.length == 11
      number.slice!(0)
    end
    return '+1' + number
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
