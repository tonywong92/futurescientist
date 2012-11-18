require 'spec_helper'

describe ProblemsController do
  include SmsSpec::Helpers

  before do
    clear_messages
  end

  describe 'sms interactions' do
    let(:twilio_phone_number) {"+16502674928"}
    let(:registered_phone_number) {"+16263204917"}
    let(:registered_phone_number2) {"+14154393733"}

    describe 'problem submission through text' do
      before do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #texted problem @San Francisco !water electrical'}
      end

      it 'should post my problem' do
        textedProblem = Problem.find_by_summary('texted problem')
        textedProblem.should_not be_nil
        textedProblem.location.should == "San Francisco"
        textedProblem.skills.should == "water electrical"
      end
    end

    describe 'requester accepting a problem through text' do
      before do
        provider_account = Account.create(:account_name => 'tony', :password => 'Password')
        provider_user = User.create(:phone_number => registered_phone_number2)
        provider_user.account = provider_account
        provider_user.save
        User.stub(:find_by_phone_number).and_return(provider_user)
        requester = User.create(:phone_number => registered_phone_number)
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #textedProblem2 @Location !water'}
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Accept textedProblem2 1'}
      end

      it 'should mark the problem as done' do
        problem = Problem.find(1)
        problem.summary.should == "textedProblem2"
        problem.archived.should == true
      end

      it 'should send a confirmation text to the provider and notify the requester' do
        open_last_text_message_for "14154393733"
        current_text_message.should have_body "You have accepted problem #1. Please contact your provider at +#{registered_phone_number2} as soon as possible."
        open_last_text_message_for "16263204917"
        current_text_message.should have_body "Your textedProblem2 problem has been accepted by tony, whom you can contact at +14154393733"
      end
    end

    describe 'problem retrieval through text' do

      before do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'ADD @Location1 !water #Problem1'}
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'ADD @Location1 !water #Problem2'}
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET @Location1 !water LIMIT 1'}
      end

      it 'should send me a list of problems with correct attributes' do
        open_last_text_message_for "+14154393734"
        current_text_message.should have_body "#{Problem.find_by_summary(Problem1)}. @Location1 !water #Problem1 $50 #{Problem.find_by_summary(Problem2)}. @Location2 !water #Problem2 $50 "
      end
    end
  end
end
