module Courtfinder
  class Postcodes < Grape::API

    desc 'Get postcodes'
    get :postcodes do
      present { sucess: true }
    end
    
  end
end