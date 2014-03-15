require 'grape-swagger'
class API < Grape::API
  version 'v1', using: :header, vendor: 'courtfinder'

  mount Courtfinder::Postcodes

  add_swagger_documentation
end