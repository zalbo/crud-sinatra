class Article < ActiveRecord::Base
  validates_presence_of :content , :title

  mount_uploader :image, AvatarUploader

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
