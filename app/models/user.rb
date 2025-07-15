class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :contacts
  has_many :messages
  has_many :user_badges
  has_many :badges, through: :user_badges
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
