class Api::V1::StoresController < Api::V1::AuthenticatedController
  before_action :set_store, only: [:show, :update, :destroy]
  protect_from_forgery with: :null_session

  def index
    @stores = Store.all
    render json: @stores
  end

  def show
    render json: @store
  end

  def create
    @store = Store.new(store_params)
    if @store.save
      render json: @store, status: :created
    else
      render json: { error: @store.errors }
    end
  end

  def update
    if @store.update(store_params)
      render json: @store
    else
      render json: { error: @store.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @store.destroy
    head 204
  end

  private 
  def store_params
    params.require(:store).permit(:name, :description, :company_id)
  end

  def set_store
    @store = Store.find(params[:id])
  end
end
