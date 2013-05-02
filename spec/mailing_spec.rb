require_relative '../mailing'

describe Mailing do

  subject(:mailing) do
    Mailing.new
  end

  context ".new" do
    it "Should instantiate a new object" do
      Mailing.new
    end
    it "Will accept Configuration Variables at instantiation" do
      mailing = Mailing.new({
        send_method: :smtp
        })
      mailing.args[:send_method].should eq :smtp
    end
  end

  context "#args" do
    it "Will accept a sleep_time attribute" do
      mailing.args[:sleep_time] = 5
      mailing.args[:sleep_time].should eq 5
    end
    it "Will has a default sleep_time attribute" do
      mailing.args[:sleep_time].should eq 3
    end
    it "Will accept a default email domain" do
      mailing.args[:default_domain] = "washington.edu"
      mailing.args[:default_domain].should eq "washington.edu"
    end
    it "Has a default send method of sendmail" do
      mailing.args[:send_method].should eq :sendmail
    end
    it "Will allow a user to set the sending method" do
      mailing.args[:send_method].should eq :sendmail
      mailing.args[:send_method] = :smtp
      mailing.args[:send_method].should eq :smtp
    end
    it "Will locate and CC shared NetID admins" do
      mailing.args[:cc_netid_admins] = true
      mailing.args[:cc_netid_admins].should be_true
    end
    it "Will not locate and CC shared NetID admins by default" do
      mailing.args[:cc_netid_admins].should be_false
    end
    it "Will accept a from attribute" do
      mailing.args[:from] = "test@example.com"
      mailing.args[:from].should eq "test@example.com"
    end
  end

  # context "Groups Service" do
  #   it "Will retrieve admins"
  # end

  # context "Groups Service CC" do
  #   it "Will cc admins"
  # end

  context "#add_message" do
    before do
      @message = Message.new
      @message.subject = "Subject"
    end
    it "Will allow a user to add to the messages variable" do
      pre_add_size = mailing.messages.size
      mailing.add_message(@message)
      mailing.messages.size.should eq pre_add_size+1
      mailing.messages.should include @message
    end
    it "Will accept a message-like object" do
      alternate_message_object = Struct.new(:subject, :body, :to, :from)
      different_message = alternate_message_object.new(subject: "Hi", to: "Nikky")
      mailing.add_message(different_message)
      mailing.messages.should include different_message
    end
    it "Will not accept an object that is not like a message" do
      bad_message_object = Struct.new(:nomethods)
      bad_message = bad_message_object.new
      mailing.add_message(bad_message)
      mailing.messages.should_not include bad_message
    end
  end

  context "#messages" do
    it "Will allow a user to select all messages" do
      mailing.messages.class.should eq Array
    end
    it "Will allow a user to manually set all messages" do
      mailing.messages = [Message.new, Message.new, Message.new]
      mailing.messages.size.should eq 3
    end
  end

  context "#do_mailing" do

    it "Will send mail if there are messages" do
      mailing.add_message(Message.new(subject: '1', to: 'test@test.com', from: 'test@test.com', body: '2'))
      mailing.do
    end
    it "Will raise and not send mail if there are no messages" do
      expect{ mailing.do}.to raise_error
    end
    it "Will raise and not send mail if there are invalid messages" do
      mailing.messages = [Message.new, Message.new, Message.new]
      expect{mailing.do}.to raise_error
    end
    it "Will write a message log" do
    end
  end
end
