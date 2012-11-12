require 'spec_helper'

describe ProblemsController do

  before do
    clear_messages
  end

  describe 'problem submission through text' do
    let(:twilio_phone_number) {"+16502674928"}
    let(:registered_phone_number) {"+14154393733"}

    before do
      post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'ADD textedProblem Location Skill'}
    end

    it 'should post my problem' do
      textedProblem = Problem.find_by_summary('textedProblem')
      textedProblem.should_not be_nil
      textedProblem.location.should == "Location"
      textedProblem.skills.should == "Skill"
    end

  describe 'problem retrieval through text' do
    let(:twilio_phone_number) {"+16502674928"}
    let(:registered_phone_number) {"+14154393733"}
    let(:registered_phone_number2) {"+14154393734"}

    before do
      post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'ADD Problem1 Location1 water'}
      post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'ADD Problem2 Location2 water'}
      post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'SEE problems someLocation water limit 1'}
    end

    it 'should send me a list of problems with correct attributes' do
        post 'create', {:phone_number => "+14154393734"}

        open_last_test_message_for "+14154393734"
        current_text_message.should have_body "Problem1 Location1 14154393733 AND Problem2 Location2 14154393733"
    end
  end
end
