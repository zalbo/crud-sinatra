require 'carrierwave/orm/activerecord'

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file

  version :thumb do
    process resize_to_fill: [0, 50]
  end

end

class Article < ActiveRecord::Base
  validates_presence_of :content , :title

  mount_uploader :image, ImageUploader

  has_many :comments


  def self.search(word)
    where("content LIKE ? OR title LIKE ? ", "%#{word}%", "%#{word}%")
  end
end

class Comment < ActiveRecord::Base
  validates_presence_of :content
  validates :email, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }

  belongs_to :article
end

class User < ActiveRecord::Base
  validates_presence_of :nickname , :password
  validates :password, length: { minimum: 3 }
  def self.authenticate(nickname, password)
    find_by(nickname: nickname, password: password)
  end

end
