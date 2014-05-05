module Courtfinder
  class Postcodes < Grape::API

    namespace :courts do

      desc 'Get postcodes'
      get :postcodes do
        @postcode_courts = PostcodeCourt.includes(:court).all
        csv = []
        CSV.generate do |csv|
          csv << ["Post code", "Court number", "Court name"]
          @postcode_courts.each do |postcode|
            csv << [postcode.postcode, postcode.court.name, postcode.court.cci_code ? postcode.court.cci_code : postcode.court.court_number]
          end
        end
        present csv
      end
    end

  end
end