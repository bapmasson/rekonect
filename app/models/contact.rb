class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :relationship
  has_many :messages
end
