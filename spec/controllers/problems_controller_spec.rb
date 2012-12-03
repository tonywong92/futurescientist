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
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #texted problem @San Francisco !water electrical $50.00'}
      end

      it 'should post my problem' do
        textedProblem = Problem.find_by_summary('texted problem')
        textedProblem.should_not be_nil
        textedProblem.location.should == "San Francisco"
        textedProblem.skills.should == "water electrical"
        textedProblem.price.should == 50.00
      end
    end

    describe 'requester accepting a problem through text' do
      before do
        provider_account = Account.create(:account_name => 'tony', :password => 'Password')
        provider_user = User.create(:phone_number => registered_phone_number2)
        provider_user.account = provider_account
        provider_user.save!
        #User.stub(:find_by_phone_number).and_return(provider_user)
        requester = User.create(:phone_number => registered_phone_number)
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #textedProblem2 @Location !water'}
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Accept 1 Password'}
      end

      it 'should mark the problem as done' do
        problem = Problem.find(1)
        problem.summary.should == "textedProblem2"
        problem.archived.should == true
      end

      it 'should send a confirmation text to the provider and notify the requester' do
        problem = Problem.find(1)
        open_last_text_message_for registered_phone_number2
        current_text_message.should have_body "You have accepted problem #1. Please contact your requester at #{registered_phone_number} as soon as possible."
      end

      it 'should send a notification to the requester' do
        open_last_text_message_for registered_phone_number
        open_last_text_message_for registered_phone_number
        current_text_message.should have_body "Your textedProblem2 problem has been accepted by tony, whom you can contact at #{registered_phone_number2}."
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

          problem = Problem.new({ :location => "Location2", :skills => "electronics", :summary => "Problem2#{i+1}", :description => "description2#{i+1}"})
          user.problems << problem
          user.save!
        end
      end

      it 'should tell me if I texted in something wrong' do
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for registered_phone_number2
        current_text_message.should have_body "Sorry, there is no saved session right now. Please first text \"GET\" with @location !skill %number of texts you want to allow."

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET @Location1 !water LIMIT asfsafas'}
        open_last_text_message_for registered_phone_number2
        current_text_message.should have_body "LIMIT must be followed by a integer number"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Edit 500'}
        open_last_text_message_for registered_phone_number
        current_text_message.should have_body "Sorry, that problem id does not exist."

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Delete 500'}
        open_last_text_message_for registered_phone_number
        current_text_message.should have_body "Sorry, that problem id does not exist."


      end

      it 'should send me a list of problems with correct attributes' do
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET @Location1 !water LIMIT 1'}
        open_last_text_message_for registered_phone_number2
        problem10 = Problem.find_by_summary("Problem10").id
        problem9 = Problem.find_by_summary("Problem9").id
        problem8 = Problem.find_by_summary("Problem8").id
        problem7 = Problem.find_by_summary("Problem7").id

        current_text_message.should have_body "id:#{problem10}. @Location1 !water #Problem10 id:#{problem9}. @Location1 !water #Problem9 id:#{problem8}. @Location1 !water #Problem8 id:#{problem7}. @Location1 !water #Problem7 "
        #current_text_message.should have_body "id:#{problem2}. @Location1 !water #Problem2 $50 id:#{problem1}. @Location1 !water #Problem1 $50 "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for registered_phone_number2
        problem6 = Problem.find_by_summary("Problem6").id
        problem5 = Problem.find_by_summary("Problem5").id
        problem4 = Problem.find_by_summary("Problem4").id
        problem3 = Problem.find_by_summary("Problem3").id

        current_text_message.should have_body "id:#{problem6}. @Location1 !water #Problem6 id:#{problem5}. @Location1 !water #Problem5 id:#{problem4}. @Location1 !water #Problem4 id:#{problem3}. @Location1 !water #Problem3 "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for registered_phone_number2
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for registered_phone_number2
        current_text_message.should have_body "There are no more additional problems for Location: Location1 Skills: water."

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET @Location2 LIMIT 1'}
        open_last_text_message_for registered_phone_number2
        problem210 = Problem.find_by_summary("Problem210").id
        problem29 = Problem.find_by_summary("Problem29").id
        problem28 = Problem.find_by_summary("Problem28").id

        current_text_message.should have_body "id:#{problem210}. @Location2 !electronics #Problem210 id:#{problem29}. @Location2 !electronics #Problem29 id:#{problem28}. @Location2 !electronics #Problem28 "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET !electronics LIMIT 1'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "id:#{problem210}. @Location2 !electronics #Problem210 id:#{problem29}. @Location2 !electronics #Problem29 id:#{problem28}. @Location2 !electronics #Problem28 "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET LIMIT 1'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "id:#{problem210}. @Location2 !electronics #Problem210 id:#{problem10}. @Location1 !water #Problem10 id:#{problem29}. @Location2 !electronics #Problem29 id:#{problem9}. @Location1 !water #Problem9 "
      end

      it 'should describe a problem correctly' do
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Describe 1'}
        open_last_text_message_for registered_phone_number2
        problem1 = Problem.find_by_summary("Problem1").id

        current_text_message.should have_body "id:#{problem1}. Description: description1 Phone: #{registered_phone_number2} "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Describe 999'}
        open_last_text_message_for registered_phone_number2

         current_text_message.should have_body "Sorry, that problem id does not exist"
      end
    end

    describe 'edit problem through text' do
      before do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #texted problem @San Francisco !water electrical $50.00'}
      end

      it 'should let me edit/delete the problem through text if it is my problem' do
       problem1_id = Problem.find_by_summary("texted problem").id
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => "Edit #{problem1_id} #new texted problem !mold electricity $49.38"}
        textedProblem = Problem.find_by_summary('new texted problem')
        textedProblem.should_not be_nil
        textedProblem.location.should == "San Francisco"
        textedProblem.skills.should == "mold electricity"
        textedProblem.price.should == 49.38
        newString = "i"
        Problem.SUMMARY_LIMIT.times do |i|
          newString << "i"
        end
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => "Edit #{problem1_id} ##{newString}"}
        open_last_text_message_for registered_phone_number
        open_last_text_message_for registered_phone_number
        open_last_text_message_for registered_phone_number
        current_text_message.should have_body "Summary is too long (maximum is #{Problem.SUMMARY_LIMIT} characters)"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => "Delete #{problem1_id}"}
        textedProblem = Problem.find_by_id(problem1_id)
        textedProblem.should be_nil
      end

      it 'should not let me edit a problem through text if it is not my problem' do
       problem1_id = Problem.find_by_summary("texted problem").id
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => "Edit #{problem1_id} #new texted problem !mold electricty $49.38"}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "Sorry. You do not have permission to edit this problem as this is not the phone number that created this problem."
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => "Delete #{problem1_id}"}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "Sorry. You do not have permission to edit this problem as this is not the phone number that created this problem."
      end
    end

     describe 'intelligent parsing of text' do
      before do
      end

      it 'should send me the right error message if I text something incorrectly' do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #texted problem @San Francisco !asdfasfsdafas $50.00'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Error. We currently do not have anyone with that skill. Text 'Skills' to get a list of skills our providers currently have."
      end

      it 'should let me be flexible with my texting' do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #texted problem @San Francisco !broken pipe $50.00'}
        textedProblem = Problem.find_by_summary('texted problem')
        textedProblem.should_not be_nil
        textedProblem.location.should == "San Francisco"
        textedProblem.skills.should == "water"
        textedProblem.price.should == 50.00
      end
    end

  end
end
