class AccountsController < ApplicationController

  def new
    @all_skills = Skill.find(:all)
    render '/accounts/new'
  end
  
  def create
    @user = User.new(params[:user])
    @account = Account.new(params[:account])
    @user.phone_number = normalize_phone(@user.phone_number)
    @account.skills = params[:skills]
    if params[:Admin] == '1'
      @account.admin = true
    else
      @account.admin = false
    end
    @user.account = @account
    save_account
    return '/accounts/new'
  end

  def save_account
    if @account.save and @user.save
      flash[:notice] = 'You have successfully created an account'
      redirect_to problems_path
    else
      flash[:error] = 'There was a problem with creating your account'
      render '/accounts/new'
    end
  end
  
  def show
    @user = Account.find_by_id(session[:account]).user
    render '/accounts/show'
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
    if @account.password == params[:account][:password]
      session[:account] = @account.id
      flash[:notice] = "Welcome, #{@account.account_name}"
      redirect_to problems_path
    else
      flash[:error] = 'Your password is incorrect'
      render '/accounts/login_form'
    end
  end
  
  def edit
    render '/accounts/edit'
  end

  def update
    @account = Account.find_by_id(session[:account])
    @account.update_attributes!(:email => params[:email][:address])
    flash[:notice] = "Email changed!"
    redirect_to '/accounts/edit'
  end

  def changepass
    @account = Account.find_by_id(session[:account])
    if params[:password][:current] != @account.password
       flash[:notice] = "Password incorrect"
       redirect_to '/accounts/edit'
    elsif params[:password_new][:new] == params[:reenter][:pass]
      @account.update_attributes!(:password => params[:password_new][:new])
      flash[:notice] = "Password changed"
      redirect_to '/accounts/edit'
    else
      flash[:notice] = "The new password you entered doesn't match"
      redirect_to '/accounts/edit'
    end
  end
  
  def normalize_phone phone_number
    if phone_number.length == 12
      phone_number.slice!(0,2)
    elsif phone_number.length == 11
      phone_number.slice!(0)
    end
    return '+1' + phone_number.gsub('(','').gsub(')','').gsub('-','').gsub('+','')
  end
  
end
