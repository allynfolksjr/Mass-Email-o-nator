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

  end

   describe "#to" do

    it "Has a to address" do
      message.to = "test@example.com"
      message.to.should eq "test@example.com"
    end

  end


  describe "#cc" do
    it "Can support cc" do
      message.cc = "derp@example.com"
      message.cc.should eq "derp@example.com"
    end

  end

  describe "#bcc" do
    it "Can support bcc" do
      message.bcc = "derp@example.com"
      message.bcc.should eq "derp@example.com"
    end

  end

end
