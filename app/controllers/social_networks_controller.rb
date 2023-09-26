class SocialNetworksController < ApplicationController
  before_action :set_company
  before_action :social_network, only: %[show edit update destroy]

  def index
    @social_networks = @company.social_networks
  end

  def show
  end

  def edit
  end

  def new
    @social_network = @company.social_networks.new
  end

  def create
    @social_network = @company.social_networks.new(social_network_params)
    if @social_network.save
      redirect_to company_social_networks_path(@company), notice: "Social Network was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
  end

  def destroy
  end

  private
  def set_company
    @company = Company.find(params[:company_id])
  end
  
  def set_social_network
    @social_network = @comapny.social_networks.find(params[:id])
  end

  def social_network_params
    params.require(:social_network).permit(:name, :url)
  end

end
