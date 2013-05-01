require_relative '../message'

describe Message do

  subject(:message) do
    Message.new
  end


  describe "#subject" do

    it "Has a subject" do
      message.subject = "Test Subject"
      message.subject.should eq "Test Subject"
    end
  end

  describe "#from" do

    it "Has a from address" do
      message.from = "test@example.com"
      message.from.should eq "test@example.com"
    end

    # it "Rejects invalid email addresses" do
    #   bad_address = "test@example@com"
    #   expect{message.from = bad_address}.to raise_error(InvalidMessageError)
    # end
  end

  describe "#recipient" do
    it "Can support recipient" do
      message.recipient = "derp@example.com"
      message.recipient.should eq "derp@example.com"
    end
  end

  describe "#cc" do
    it "Can support cc" do
      message.recipient = "derp@example.com"
      message.recipient.should eq "derp@example.com"
    end
  end

  describe "#bcc" do
    it "Can support bcc" do
      message.recipient = "derp@example.com"
      message.recipient.should eq "derp@example.com"
    end
  end
end
