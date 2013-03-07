class ApplicationController < ActionController::Base
  protect_from_forgery
  
  TWILIO = "+16502674928"
  TEXTLENGTH = 160
  
  def sms_authenticate
    if @client == nil
      account_sid = 'AC7bec7276c109417979adfc442a675fc9'
      auth_token ='6ca5a284c956fc0a444ba453ca63508b'
      @client = Twilio::REST::Client.new(account_sid, auth_token)
    end
  end

  def sms_error(error_string)
    sms_authenticate
    current = 0;
    (error_string.length/(TEXTLENGTH.to_f)).ceil.times do |i|
      @client.account.sms.messages.create(:from => params[:To], :to => params[:From], :body => error_string.slice(current, current + TEXTLENGTH))
      current += TEXTLENGTH
     end
  end

  def sms_send(*args)
    if(args.size == 1)
	    string = args[0]
	    sms_authenticate
	    current = 0;
	    (string.length/(TEXTLENGTH.to_f)).ceil.times do |i|
	      @client.account.sms.messages.create(:from => params[:To], :to => params[:From], :body => string.slice(current, current + TEXTLENGTH))
	      current += TEXTLENGTH
	     end
    else
 	phone_number = args[0]
	string = args[1]
    	sms_authenticate
    	@client.account.sms.messages.create(:from => TWILIO, :to => phone_number, :body => string)
    end
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
