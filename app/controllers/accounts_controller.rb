require 'rubygems'
require 'openssl'
require 'base64'
require 'cgi'
require 'hmac-sha1'

class AccountsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  # Test numbers: When you create an account in rails server, you need to use one of these numbers. Otherwise it will try to send a text to confirm the number you are using and it will fail.
  TEST_NUMBERS = ["+11234567890", "+19994441111", "+10008882222", "+16667777888", "+12223334444"]

  
  # Loads the account creation form
  def new
#    @all_skills = Skill.find(:all)
  end

  # Creates a new account after user submits the account creation form.
  # In production, we require a confirmation text to be sent and received in order to create an account
  def create
    #@all_skills = Skill.find(:all)
    phone_number = normalize_phone(params[:account][:phone_number].strip)
    params[:account][:phone_number] = phone_number
    if phone_number
      if params[:account][:password].empty?
        flash[:notice] = 'Password is a required field.'
      end
      @account = Account.new(params[:account])
      if params[:Admin] == '1'
        @account.admin = true
        #@account.verified_skills = params[:skills]
      else
        @account.admin = false
        #@account.skills = params[:skills]
        #@sv = SkillVerification.new
        #@sv.account = @account
        #@sv.save!
      end
      save_account phone_number
    else
      flash[:notice] = 'Phone Number is a required field.'
      render new_account_path
    end
  end

  def save_account phone_number
    if TEST_NUMBERS.include? phone_number
      if @account.save
        session[:account] = !Account.find_by_id(session[:account]).nil?
        flash[:notice] = 'You have successfully created an account'
        #don't require a text confirmation
        @account.verified = true
        @account.save
      else
        flash[:error] = 'There was a problem with creating your account'
        if !@account.errors.empty?
          flash[:account_errors] = @account.errors.full_messages
        end
        @account.destroy
        #@all_skills = Skill.find(:all)
        redirect_to new_account_path
        return
      end
    else
      begin
        if @account.save
          sms_send(@account.phone_number, "If you have created an account at Emplify, please reply to this text with the number: #{@account.id}.")
          reset_session unless !Account.find_by_id(session[:account]).nil?
        else
          flash[:error] = 'There was a problem with creating your account'
          if !@account.errors.empty?
            flash[:account_errors] = @account.errors.full_messages
          end
          @account.destroy
          #@all_skills = Skill.find(:all)
          redirect_to new_account_path
          return
        end
        flash[:notice] = "Your account has been created, but will not be verified until you have replied to the text with the number indicated. Until you verify, you will not be able to login."
      rescue Twilio::REST::RequestError
        flash[:notice] = 'We seem to be having difficulties sending a text to your phone number. Please try another valid phone number or try again later.'
        @account.destroy
        render new_account_path
        return
      end
    end
    redirect_to problems_path
  end

  def show
    @account = Account.find_by_id(session[:account])
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
    elsif !@account.verified
      flash[:error] = 'This account has not yet been verified. Please respond to the text you received with the confirmation nuberm.'
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
    if @account.has_password?(params[:account][:password])
      session[:account] = @account.id
      flash[:notice] = "Welcome, #{@account.account_name}"
      redirect_to problems_path
    else
      flash[:error] = 'Your password is incorrect'
      render '/accounts/login_form'
    end
  end

  def edit
    account = Account.find_by_id(session[:account])
    @account_email = account.email
    @user_phone = account.phone_number
    @user_location = "99999"
    #@all_skills = Skill.find(:all)
    #@skills_array = Array.new
  end

  def update
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to problems_path
    elsif params[:type] == 'edit_email'
      if @account.update_attributes(:email => params[:email][:address])
     	 flash[:notice] = "Email changed!"
      else
         flash[:notice] = @account.errors.full_messages
      end	
      redirect_to edit_account_path(@account.id)
    elsif params[:type] == 'edit_password'
      changepass
    elsif params[:type] == 'edit_phone'
      changenumber
    elsif params[:type] == 'edit_location'
      changelocation
    #elsif params[:type] == 'edit_skills'
    #  changeskills
    end
  end

  def changepass
    @account = Account.find_by_id(session[:account])
    if @account.nil?
       flash[:notice] = "You are not logged in"
       redirect_to problems_path
    elsif !@account.has_password?(params[:password][:current])
       flash[:notice] = "Password incorrect"
       redirect_to edit_account_path(@account.id)
    elsif params[:password_new][:new] == params[:reenter][:pass]
      if @account.update_attributes(:password => params[:password_new][:new])
     	 flash[:notice] = "Password changed"
      else
         flash[:notice] = @account.errors.full_messages
      end
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
      if @account.update_attributes(:phone_number => phoneNum)
     	 flash[:notice] = "Phone number changed"
      else
         flash[:notice] = @account.errors.full_messages
      end
      redirect_to edit_account_path(@account.id)
    end
  end

  def changelocation
    @account = Account.find_by_id(session[:account])

    if @account.nil?
      flash[:notice] = "You are not logged in"
      redirect_to problems_path
    else
      newLocation = params[:location][:name].downcase
      if @account.update_attributes(:location => newLocation)
     	 flash[:notice] = "Location changed"
      else
         flash[:notice] = @account.errors.full_messages
      end
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
      if @account.update_attributes(:verified_skills => params[:skills])
     	 flash[:notice] = "Skills updated"
      else
         flash[:notice] = @account.errors.full_messages
      end
      redirect_to edit_account_path(@account.id)
    else
      if @account.update_attributes(:skills => params[:skills])
      	flash[:notice] = "Skills to be verified"
      else
         flash[:notice] = @account.errors.full_messages
      end
      redirect_to edit_account_path(@account.id)
    end
  end

  def forgot_password
    @twilio = TWILIO
    render '/accounts/forgot_password'
  end

  def forgot_account
    @twilio = TWILIO
    render '/accounts/forgot_account'
  end
end
