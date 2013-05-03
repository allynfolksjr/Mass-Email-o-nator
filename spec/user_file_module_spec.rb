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
        data2: 'data',
        data3: 'as',
        data4: 'required'
      }

      UserFile::parse(file)[0].should eq expected_result

    end
  end
end
