class Api::V1::CategoriesController < Api::V1::AuthenticatedController
  before_action :set_category, only: [:show, :update, :destroy]
  protect_from_forgery with: :null_session

  def index
    @categories = Category.all
    render json: @categories
  end

  def show
    render json: @category
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render json: @category, status: :created
    else
      render json: { error: @category.errors }
    end
  end

  def update
    if @category.update(category_params)
      render json: @category
    else
      render json: { error: @category.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    head 204
  end

  private 
  def category_params
    params.require(:category).permit(:name, :tag_name, :description)
  end

  def set_category
    @category = Category.find(params[:id])
  end

  end