class User < ApplicationRecord
  has_secure_password
  #validates :name, presence: true
  validates :email, presence: true,
                    format: {with: /\S+@\S+/},
                    uniqueness: {case_sensitive: false}

  validates :password, length: {minimum: 8, allow_blank: true}

  has_many :api_tokens
  has_many :products

end
