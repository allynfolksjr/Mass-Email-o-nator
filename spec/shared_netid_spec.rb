require_relative '../shared_netid'

describe SharedNetid do

  subject(:sharedNetid) do
    SharedNetid.new({
      cert: File.read("/home/nikky/nikky_cac_washington_edu.cert"),
      key: File.read("/home/nikky/nikky_cac_washington_edu.key")
      })
  end

  context "::new" do

    it "Should instantiate a new object" do
      SharedNetid.new({
      cert: File.read("/home/nikky/nikky_cac_washington_edu.cert"),
      key: File.read("/home/nikky/nikky_cac_washington_edu.key")
      }).should_not be_nil
    end

    it "Should not instantiate without a cert" do
      expect {SharedNetid.new({
      key: File.read("/home/nikky/nikky_cac_washington_edu.key")
      })}.to raise_error
    end

    it "Should not instantiate without a key" do
      expect {SharedNetid.new({
      cert: File.read("/home/nikky/nikky_cac_washington_edu.cert")
      })}.to raise_error
    end

  end

  context "#check_for_shared_netid" do
    it "Should return true if a NetID is shared" do
      sharedNetid.check_for_shared_netid("sqltest").should eq ["nikky"]
    end

    it "Should return false if a NetID is not shared" do
      sharedNetid.check_for_shared_netid("nikky").should be_false
    end
  end
end
