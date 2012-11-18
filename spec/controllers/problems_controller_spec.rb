require 'spec_helper'

describe ProblemsController do
  include SmsSpec::Helpers

  before do
    clear_messages
  end

  describe 'sms interactions' do
    let(:twilio_phone_number) {"+16502674928"}
    let(:registered_phone_number) {"+14154393733"}
    let(:registered_phone_number2) {"+14154393734"}

    describe 'problem submission through text' do
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

    describe 'requester accepting a problem through text' do
      before do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'ADD textedProblem Location Skill'}
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'ACCEPT textedProblem 1'}
      end

      it 'should remove the specified problem from the index and assign it to the provider account' do
        problem = Problem.find(1)
        problem.accepted.should == true
        provider = User.find_by_phone_number(registered_phone_number).account
        provider.accepted_problems.include?(problem).should == true
      end

      it 'should send a confirmation text to the provider' do
        open_last_text_message_for "14154393733"
        current_text_message.should have_body "You have successfully accepted this problem! Please contact the requester as soon as possible"
      end
    end

    describe 'problem retrieval through text' do

      before do
        NUM_PROBLEMS = 10
        user = User.new({ :name => "dummy1", :phone_number=> registered_phone_number2, :location => "Address1"})
        user.save!
        NUM_PROBLEMS.times do |i|
          problem = Problem.new({ :location => "Location1", :skills => "water", :summary => "Problem#{i+1}", :description => "description#{i+1}"})
          user.problems << problem
          user.save!
        end
      end

      it 'should tell me if I texted in something wrong' do
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for "+14154393734"
        current_text_message.should have_body "Sorry, there is no saved session right now. Please first text \"GET\" with @location !skill %number of texts you want to allow."
      end

      it 'should send me a list of problems with correct attributes' do
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET @Location1 !water LIMIT 1'}
        open_last_text_message_for "+14154393734"
        problem10 = Problem.find_by_summary("Problem10").id
        problem9 = Problem.find_by_summary("Problem9").id
        problem8 = Problem.find_by_summary("Problem8").id
        problem7 = Problem.find_by_summary("Problem7").id

        current_text_message.should have_body "id:#{problem10}. @Location1 !water #Problem10 id:#{problem9}. @Location1 !water #Problem9 id:#{problem8}. @Location1 !water #Problem8 id:#{problem7}. @Location1 !water #Problem7 "
        #current_text_message.should have_body "id:#{problem2}. @Location1 !water #Problem2 $50 id:#{problem1}. @Location1 !water #Problem1 $50 "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for "+14154393734"
        problem6 = Problem.find_by_summary("Problem6").id
        problem5 = Problem.find_by_summary("Problem5").id
        problem4 = Problem.find_by_summary("Problem4").id
        problem3 = Problem.find_by_summary("Problem3").id

        current_text_message.should have_body "id:#{problem6}. @Location1 !water #Problem6 id:#{problem5}. @Location1 !water #Problem5 id:#{problem4}. @Location1 !water #Problem4 id:#{problem3}. @Location1 !water #Problem3 "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for "+14154393734"
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for "+14154393734"
        current_text_message.should have_body "There are no more additional problems for Location: Location1 Skills: water."
      end

      it 'should describe a problem correctly' do
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Describe 1'}
        open_last_text_message_for "+14154393734"
        problem1 = Problem.find_by_summary("Problem1").id

        current_text_message.should have_body "id:#{problem1}. Description: description1 Phone: #{registered_phone_number2} "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Describe 999'}
        open_last_text_message_for "+14154393734"

         current_text_message.should have_body "Sorry, that problem id does not exist"
      end
    end
  end
end
