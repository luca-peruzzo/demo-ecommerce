class CompaniesController < ApplicationController
  def index
    @companies = Company.all
  end

  def show
    @company = Company.find(params[:id])
  end

  def edit
    @company = Company.find(params[:id])
  end

  def new
    @company = Company.new
  end

  def create 
    @company = Company.new(company_params)
    if @company.save
      redirect_to @company, notice: "Comany was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @company = Company.find(params[:id])
    if @company.update(company_params)
      redirect_to @company, notice: "Company was successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    redirect_to companies_path
  end



  private
  def company_params
    params.require(:company).permit(:name, :description, :tag_title, :meta_decrition, :web_site)
  end

end
