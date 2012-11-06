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
    
  end
end