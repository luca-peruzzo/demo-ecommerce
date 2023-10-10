class Api::V1::CompaniesController < Api::V1::AuthenticatedController
  before_action :set_company, only: [:show, :update, :destroy]
  protect_from_forgery with: :null_session

  def index
    @companies = Company.all
    render json: @companies
  end

  def show
    render json: @company
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      render json: @company, status: :created
    else
      render json: { error: @company.errors }
    end
  end

  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: { error: @company.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    head 204
  end

  private
  def company_params
    params.require(:company).permit(:name, :description, :tag_title, :meta_description, :web_site)
  end

  def set_company
    @company = Company.find(params[:id])
  end
end