class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :profile_image

validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
validates :introduction, length: {maximum: 50}


  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followings, through: :relationships, source: :followed

  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :reverse_of_relationships, source: :follower

  has_many :user_rooms
  has_many :chats
  has_many :rooms, through: :user_rooms
  
  has_many :view_counts, dependent: :destroy


  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  def is_followed_by?(user)
    reverse_of_relationships.find_by(follower_id: user.id).present?
  end

  def self.looks(search, word)
    if search == "perfect_match"
      @user = User.where("name LIKE?", "#{word}")
    elsif search == "forward_match"
      @user = User.where("name LIKE?","#{word}%")
    elsif search == "backward_match"
      @user = User.where("name LIKE?","%#{word}")
    elsif search == "partial_match"
      @user = User.where("name LIKE?","%#{word}%")
    else
      @user = User.all
    end
  end
end
