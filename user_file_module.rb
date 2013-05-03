require 'csv'

module UserFile

  def self.parse(file)

    data_set = []

    csv_options = {
      headers: true,
      header_converters: :symbol
    }

    CSV.foreach(file, csv_options) do |r|

      row_data = {}

      r.each do |k,v|
        row_data[k] = v
      end

      data_set << row_data

    end

    data_set

  end

end
