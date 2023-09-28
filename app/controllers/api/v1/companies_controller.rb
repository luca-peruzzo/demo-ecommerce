class Api::V1::CompaniesController < ApplicationController
    def index
        @companies = Company.all
        render json: @companies
    end

    def show
        @company = Company.find(params[:id])
        render json: @company
    end
end