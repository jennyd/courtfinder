# TODO: this can be refactored into a nice DSL
class ApiDocsController < ApplicationController

  respond_to :html, :json

  def index
    respond_to do |format|
      format.html
      # format.json do
      #   render json: header_fields.merge({
      #     apis: [
      #       { path: "/api_docs/sync.{format}" },
      #       { path: "/api_docs/credentials.{format}" }
      #     ]
      #   })
      # end
    end
  end
  
end