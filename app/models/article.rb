class Article < ApplicationRecord
    has_many :article_tags
    has_many :tags, through: :article_tags

    scope :filter_by_title, lambda { |keyword| where('lower(title) LIKE ?', "%#{keyword.downcase}%")}

    def self.search(params = {})
      articles = Article.all

      articles = articles.filter_by_title(params[:title]) if params[:title]

      articles
    end
end
