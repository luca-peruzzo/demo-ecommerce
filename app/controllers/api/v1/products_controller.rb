class Api::V1::ProductsController < Api::V1::AuthenticatedController

=begin
  def index
    @products = Product.all
    render json: @products
  end
=end
  def index
    @products = Product.search(params)
    #render json: ProductSerializer.new(@products).serializable_hash.to_json
    render json: @products 
   
  end

  def show 
    @product = Product.find(params[:id])
    render json: @product
    #render json: ProductSerializer.new(@product).serializable_hash.to_json
    
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  end

  def update 
    @product = Product.find(params[:id])
    if @product.update(product_params)
      render json: @product
    else
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  end


  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    head 204
  end



  private
  def product_params
    params.require(:product).permit(:name, :description, :price)
  end


end
