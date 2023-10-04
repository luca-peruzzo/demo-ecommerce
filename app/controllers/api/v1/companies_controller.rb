class Api::V1::CompaniesController < ActionController::Base
    def index
        @companies = Company.all
        render json: @companies
    end

    def show
        @company = Company.find(params[:id])
        render json: @company
    end
end