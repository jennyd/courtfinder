require 'grape-swagger'
class API < Grape::API
  version 'v1', using: :header, vendor: 'courtfinder'
  
  # content_type :json, 'application/json'
  # content_type :csv, 'text/csv'

  # format :json
  # format :csv

  # default_format :json

  mount Courtfinder::Postcodes

  add_swagger_documentation
end