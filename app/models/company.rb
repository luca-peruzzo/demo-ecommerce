class Company < ApplicationRecord
    has_many :social_networks, dependent: :destroy
end
