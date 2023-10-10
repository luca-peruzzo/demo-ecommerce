class Api::V1::SocialNetworksController < Api::V1::AuthenticatedController
  before_action :set_social_network, only: [:show, :update, :destroy]
  protect_from_forgery with: :null_session

  def index
    @social_networks = SocialNetwork.all
    render json: @social_networks
  end

  def show
    render json: @social_network
  end

  def create
    @social_network = SocialNetwork.new(social_network_params)
    if @social_network.save
      render json: @social_network, status: :created
    else
      render json: { error: @social_network.errors }
    end
  end

  def update
    if @social_network.update(social_network_params)
      render json: @social_network
    else
      render json: { error: @social_network.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @social_network.destroy
    head 204
  end

  private 
  def social_network_params
    params.require(:social_network).permit(:name, :url, :company_id)
  end

  def set_social_network
    @social_network = SocialNetwork.find(params[:id])
  end

end
