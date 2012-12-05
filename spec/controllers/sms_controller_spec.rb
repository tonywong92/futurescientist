require 'spec_helper'

describe SmsController do
  include SmsSpec::Helpers
  let(:twilio_phone_number) {"+16502674928"}
  let(:registered_phone_number) {"+16263204917"}
  let(:registered_phone_number2) {"+14154393733"}

  before do
    clear_messages
    Skill.create(:skill_name => "water")
    Skill.create(:skill_name => "water electrical")
    Skill.create(:skill_name => "electronics")
    Skill.create(:skill_name => "mold electricity")
    user = User.new(:name => "Test", :phone_number => registered_phone_number)
    user.save!
    account = Account.new(:account_name => "testaccount", :password => "Password", :email => "test2@test.com")
    user.account = account
    user.save!
  end

  describe 'sms interactions' do

    describe 'problem submission through text' do

      before do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #texted problem @San Francisco !water electrical $50.00'}
      end

      it 'should post my problem' do
        textedProblem = Problem.find_by_summary('texted problem')
        textedProblem.should_not be_nil
        textedProblem.location.should == "san francisco"
        textedProblem.skills.should == "water electrical"
        textedProblem.wage.should == 50.00
      end
    end

    describe 'requester accepting a problem through text' do

      before do
        provider_account = Account.create(:account_name => 'tony', :password => 'Password', :email => 'test@test.com')
        provider_account.verified_skills << 'water'
        provider_user = User.create(:phone_number => registered_phone_number2)
        provider_user.account = provider_account
        provider_user.save!
        requester = User.create(:phone_number => registered_phone_number)
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #textedProblem2 @Location !water $50.00'}
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
          problem = Problem.new({ :location => "Location1", :skills => "water", :summary => "Problem#{i+1}", :description => "description#{i+1}", :wage => 50.00})
          user.problems << problem
          user.save!

          problem = Problem.new({ :location => "Location2", :skills => "electronics", :summary => "Problem2#{i+1}", :description => "description2#{i+1}", :wage => 50.00})
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

        problem10 = Problem.find_by_summary("Problem10").id
        problem9 = Problem.find_by_summary("Problem9").id
        problem8 = Problem.find_by_summary("Problem8").id
        problem7 = Problem.find_by_summary("Problem7").id
        problem6 = Problem.find_by_summary("Problem6").id
        problem5 = Problem.find_by_summary("Problem5").id
        problem4 = Problem.find_by_summary("Problem4").id
        problem3 = Problem.find_by_summary("Problem3").id

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET @Location1 !water LIMIT 1'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "id:#{problem10}. @location1 !water #Problem10 $50.0 id:#{problem9}. @location1 !water #Problem9 $50.0 id:#{problem8}. @location1 !water #Problem8 $50.0"
        #current_text_message.should have_body "id:#{problem2}. @Location1 !water #Problem2 $50 id:#{problem1}. @Location1 !water #Problem1 $50 "

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "id:#{problem7}. @location1 !water #Problem7 $50.0 id:#{problem6}. @location1 !water #Problem6 $50.0 id:#{problem5}. @location1 !water #Problem5 $50.0"

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for registered_phone_number2
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'NEXT 1'}
        open_last_text_message_for registered_phone_number2
        current_text_message.should have_body "There are no more additional problems for Location: location1 Skills: water."
      end

      it 'should be flexible with what fields I want to filter by' do

        problem210 = Problem.find_by_summary("Problem210").id
        problem29 = Problem.find_by_summary("Problem29").id
        problem28 = Problem.find_by_summary("Problem28").id
        problem10 = Problem.find_by_summary("Problem10").id

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET @Location2 LIMIT 1'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "id:#{problem210}. @location2 !electronics #Problem210 $50.0 id:#{problem29}. @location2 !electronics #Problem29 $50.0 id:#{problem28}. @location2 !electronics #Problem28 $50.0"

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET !electronics LIMIT 1'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "id:#{problem210}. @location2 !electronics #Problem210 $50.0 id:#{problem29}. @location2 !electronics #Problem29 $50.0 id:#{problem28}. @location2 !electronics #Problem28 $50.0"

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'GET LIMIT 1'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "id:#{problem210}. @location2 !electronics #Problem210 $50.0 id:#{problem10}. @location1 !water #Problem10 $50.0 id:#{problem29}. @location2 !electronics #Problem29 $50.0"
      end

      it 'should describe a problem correctly' do

        problem1 = Problem.find_by_summary("Problem1").id

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Describe 1'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "id:#{problem1}. Description: description1"

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
        textedProblem.location.should == "san francisco"
        textedProblem.skills.should == "mold electricity"
        textedProblem.wage.should == 49.38
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

      it 'should allow me to be flexible with the order of the fields I send' do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add @San Francisco #texted problem1 !water $50.00'}
        textedProblem1 = Problem.find_by_summary("texted problem1").id
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "You have successfully posted your problem(id: #{textedProblem1}). We will notify you of any updates as soon as possible. Thank you for using Emplify!"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add $50.00 !water #texted problem2 @San Francisco'}

        textedProblem2 = Problem.find_by_summary("texted problem2").id
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "You have successfully posted your problem(id: #{textedProblem2}). We will notify you of any updates as soon as possible. Thank you for using Emplify!"
      end

      it 'should send me the right error message if I text something incorrectly' do
        num_skills_to_add = 18
        num_skills_to_add.times do |i|
          Skill.create(:skill_name => "skillname#{i+1}")
        end
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Add #texted problem @San Francisco !asdf $50.00'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Skills : asdf is not a current skill we have. Text 'Skills' to get a list of skills we currently have."
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Get @San Francisco !asdf $50.00'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Skills: asdf is not a current skill we have. Text 'Skills' to get a list of skills we currently have."
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Skills'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "water, water electrical, electronics, mold electricity, skillname1, skillname2, skillname3, skillname4, skillname5, skillname6, skillname7, skillname8"

        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "skillname9, skillname10, skillname11, skillname12, skillname13, skillname14, skillname15, skillname16, skillname17, skillname18"
      end

      it 'should guide me if I am completely lost in using the SMS framework' do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'randomKeyWord'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Wrong keyword. Text 'keywords' to get the list of valid keywords"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'keywords'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Get, Add, Accept, Delete, Next, Detail, Edit, Skills are the valid keywords. Text 'Explain [keyword]' to get a description of the keyword."

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Explain add'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Create a Problem: Text Add #[Problem Summary] ![Skills Needed] @[Location] $[Wage]'"


        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Explain get'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Get a List of Problems: Text 'Get ![Filter by this skill] @[Filter by this location] LIMIT [Amount of texts you want to recieve]'"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Explain accept'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Accept a Problem if you are a verified provider: Text 'Accept [Problem ID] [Password to your account]'"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Explain delete'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Delete a Problem: Text 'Delete [Problem Id]'"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Explain next'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Continues the list of your previous 'GET' text with the same fields: Text 'Next [Amount of texts you want to recieve]'"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Explain detail'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "More details on a specific problem: Text 'Detail [Problem ID]'"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Explain edit'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Edit a Problem: Text 'Edit [Problem Id] #[New Problem Summary] ![New Skills Needed] @[New Location] $[New Wage]'"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Explain skills'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "A list of skills we currently have: Text 'Skills'"
      end
    end

     describe 'forgot account or password' do
      before do
      end

      it 'should send informative texts during the process of forgot password/account' do
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Account'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Your account name is testaccount"
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Password'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Please text back 'change [new password]' Please keep in mind that your password must be at least 6 characters with 1 capital letter."
        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Change Password2'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Your password has successfully been changed."

        account = Account.find_by_account_name("testaccount")
        account.should_not be_nil
        assert account.has_password?("Password2"), "Password is suppose to be: Password2"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Change undercased'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Password needs to have at least 1 capital letter"

        post :receive_sms, {:From => registered_phone_number, :To => twilio_phone_number, :Body => 'Change ASDF'}
        open_last_text_message_for registered_phone_number

        current_text_message.should have_body "Password is too short (minimum is 6 characters)"
      end

      it 'should give correct errors if I do not have an account' do
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Account'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "There is no account associated with this number."

        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Password'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "There is no account associated with this number."
        post :receive_sms, {:From => registered_phone_number2, :To => twilio_phone_number, :Body => 'Change Password2'}
        open_last_text_message_for registered_phone_number2

        current_text_message.should have_body "Sorry, please send another request 'password' to this number."
      end
    end

  end
end
