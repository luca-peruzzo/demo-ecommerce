class Api::V1::HomeController < ActionController::Base
    def index
        render json: {message: "Hello API world!"}
    end
end