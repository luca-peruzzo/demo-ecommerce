class Api::V1::ArticlesController < Api::V1::AuthenticatedController
  before_action :set_article, only: [:show, :update, :destroy]
  protect_from_forgery with: :null_session

  def index
    @articles = Article.all
    render json: @articles
  end

  def show
    render json: @article
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      render json: @article, status: :created
    else
      render json: { error: @article.errors }
    end
  end

  def update
    if @article.update(article_params)
      render json: @article
    else
      render json: { error: @article.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    head 204
  end

  private 
  def article_params
    params.require(:article).permit(:title)
  end

  def set_article
    @article = Article.find(params[:id])
  end

end
