class Api::V1::OrdersController < ActionController::Base
  before_action :set_order, only: [:show, :update, :destroy]
  protect_from_forgery with: :null_session

  def index
    @orders = Order.all
    render json: @orders
  end

  def show
    render json: @order
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      render json: @order, status: :created
    else
      render json: { error: @order.errors }
    end
  end

  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: { error: @order.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    head 204
  end

  private 
  def order_params
    params.require(:order).permit(:total, :user_id)
  end

  def set_order
    @order = Order.find(params[:id])
  end

end
