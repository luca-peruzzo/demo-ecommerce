class Api::V1::OrdersController < Api::V1::AuthenticatedController
    
    def index
        @orders = Order.all
        render json: OrderSerializer.new(@orders).serializable_hash.to_json
    end

    def show
        @order = Order.find(params[:id])
        if @order
            options = { include: [:products] }
            render json: OrderSerializer.new(@order, options).serializable_hash.to_json
        else
            head 404
        end
    end
    

    def create
        @order = Order.new(order_params)
        if @order.save
            render json: order, status: 201
        else
            render json: { errors: @order.errors }, status: 422
        end
    end

    def order_params
        params.require(:order).permit(:total, product_ids: [])
    end

end
