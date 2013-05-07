require_relative '../user_file_module'


describe UserFile do

  subject(:file) do
    file = File.expand_path("../mocks/csv_user_file.txt", __FILE__)
  end


  context 'Basic Things' do
    it "it exists" do
      UserFile.should be_true
    end
  end

  context '::parse' do
    it "Will parse a CSV-formatted file and return an array of hashes" do
      expected_result = {
        to: 'nikky',
        cc: 'webtest',
        bcc: 'sqltest',
        data1: 'additional',
        data2: 'data a',
        data3: 'as',
        data4: 'required'
      }

      results = UserFile::parse(file)
      results[0].should eq expected_result
      results.size.should eq 3

    end
    it "Will parse a CSV-formatted file with empty field and return an array of hashes" do
      expected_result = {
        to: 'nikky',
        cc: 'webtest',
        bcc: 'sqltest',
        data1: 'additional',
        data2: 'data b',
        data3: nil,
        data4: 'required'
      }
      results = UserFile::parse(file)
      results[1].should eq expected_result
      results.size.should eq 3


    end
  end
end
