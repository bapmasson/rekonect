class Relationship < ApplicationRecord
  has_many :contacts

  # Type
  validates :relation_type, presence: true, length: { minimum: 2, maximum: 50 }

  # Proximité ( 1 à 10 par défaut mais modifiable)

  validates :proximity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
end
