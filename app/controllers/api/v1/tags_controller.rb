class Api::V1::TagsController < Api::V1::AuthenticatedController
  before_action :set_tag, only: [:show, :update, :destroy]
  protect_from_forgery with: :null_session

  def index
    @tags = Tag.all
    render json: @tags
  end

  def show
    render json: @tag
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render json: @tag, status: :created
    else
      render json: { error: @tag.errors }
    end
  end

  def update
    if @tag.update(tag_params)
      render json: @tag
    else
      render json: { error: @tag.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy
    head 204
  end

  private 
  def tag_params
    params.require(:tag).permit(:name)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end

end
