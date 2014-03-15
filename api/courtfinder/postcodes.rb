module Courtfinder
  class Postcodes < Grape::API

    desc 'Get postcodes'
    get :postcodes do
      present success: true
    end

  end
end