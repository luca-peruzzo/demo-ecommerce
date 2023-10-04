class Api::V1::CategoriesController < ActionController::Base
    def index
      @categories = Category.all
      render json: @categories
    end
  
    def show 
      @category = Category.find(params[:id])
      render json: @category
    end
  
  end