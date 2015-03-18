
require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'sinatra'
require 'sqlite3'
require 'logger'
require 'pry'


ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
:adapter => 'sqlite3',
:database => 'zalbo.db'
)

class CreateMessageMigration < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :email
      t.text :content
    end
  end
end

class CreateCommentMigration < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :message_id
      t.text :email
      t.text :content
    end
  end
end

class CreateUserMigration < ActiveRecord::Migration
  def change
    create_table :Users do |t|
      t.text :nickname
      t.text :password
    end
  end
end

ActiveRecord::Migrator.migrate CreateMessageMigration
ActiveRecord::Migrator.migrate CreateCommentMigration
ActiveRecord::Migrator.migrate CreateUserMigration

begin
  CreateMessageMigration.new.migrate(:up)
rescue ActiveRecord::StatementInvalid
  puts "table messages already exists"
end

begin
  CreateCommentMigration.new.migrate(:up)
rescue ActiveRecord::StatementInvalid
  puts "table comments already exists"
end

begin
  CreateUserMigration.new.migrate(:up)
rescue ActiveRecord::StatementInvalid
  puts "table users already exists"
end

#####################################

class Message < ActiveRecord::Base
  validates_presence_of :content
  validates :email, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }

  has_many :comments

  def self.search(word)
    where("content LIKE ? OR email LIKE ? ", "%#{word}%" , "%#{word}%")
  end
end

class Comment < ActiveRecord::Base
  validates_presence_of :content
  validates :email, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }

  belongs_to :message
end

class User < ActiveRecord::Base
  validates_presence_of :nickname , :password
  validates :password, length: { minimum: 3 }

  def self.authenticate(nickname, password)
    where(nickname: nickname, password: password).count > 0
  end

end

enable :sessions

#####################################
get '/' do

  session[:search] = nil if params[:search] == ""
  params[:search] = session[:search] if session[:search] && params[:search].nil?

  if params[:search]
    @messages = Message.search(params[:search])
    session[:search] = params[:search]
  else
    @messages = Message.all
  end
  erb :index
end

get '/new' do
  access_danied unless session[:logged]
  @message = Message.new

  erb :new
end

get '/show/:id' do
  @message = Message.find(params[:id].to_i)
  @comment = Comment.new(message_id: @message.id)

  erb :show
end

get '/edit/:id' do
  access_danied unless session[:logged]
  @message = Message.find(params[:id].to_i)

  erb :edit
end

get '/delete/:id' do
  access_danied unless session[:logged]
  Message.find(params[:id].to_i).destroy
  redirect('/')
end

get '/login' do
  @user_errors = User.new

  erb :login
end

get '/logout' do
  session[:logged] = false
  redirect('/')
end


post '/' do
  @message = Message.new(params)

  if @message.save
    redirect('/')
  else
    erb :new
  end
end

post '/edit/:id' do

  @message = Message.find(params[:id].to_i)

  if @message.update(message_params(params))
    redirect('/')
  else
    erb :edit
  end
end

post '/comment' do

  @message = Message.find(params[:message_id].to_i)
  @comment = @message.comments.build

  if @comment.update(message_params(params))
    redirect("/show/#{@message.id}")
  else
    erb :show
  end
end

post '/login' do


  if User.authenticate(params[:nickname], params[:password])
    session[:logged] = true
    session[:nickname] = params[:nickname]
    redirect('/')
  else
    @user_errors = User.create(params)
    erb :login
  end
end

def message_params(params)
  params.delete("splat")
  params.delete("capture")
  params
end

def access_danied
  halt 403, erb(:error)
end
