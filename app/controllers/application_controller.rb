class ApplicationController < ActionController::Base
  protect_from_forgery
  
  TWILIO = "+16502674928"
  
  def sms_authenticate
    if @client == nil
      account_sid = 'ACafb3d0d7820d6b39613ffdc47d5f074f'#'AC7bec7276c109417979adfc442a675fc9'#'ACafb3d0d7820d6b39613ffdc47d5f074f'
      auth_token ='71aedf3c912ea6f64b719d671adea8b3'#'6ca5a284c956fc0a444ba453ca63508b'#'71aedf3c912ea6f64b719d671adea8b3'
      @client = Twilio::REST::Client.new(account_sid, auth_token)
    end
  end

  def sms_error(error_string)
    sms_authenticate
    @client.account.sms.messages.create(:from => params[:To], :to => params[:From], :body => error_string)
  end

  def sms_send(string)
    sms_authenticate
    @client.account.sms.messages.create(:from => params[:To], :to => params[:From], :body => string)
  end
  
  def sms_send(phone_number, string)
    sms_authenticate
    @client.account.sms.messages.create(:from => TWILIO, :to => phone_number, :body => string)
  end
  
  def is_num?(str)
    Integer(str)
    rescue ArgumentError
      false
    else
      true
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
  
end
