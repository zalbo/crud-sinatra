
require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'sinatra'
require 'sqlite3'
require 'logger'
require 'pry'
require 'encrypted_cookie'
require './models'

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
    find_by(nickname: nickname, password: password)
  end

end


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
  access_danied unless current_user
  @message = Message.new

  erb :new
end

get '/show/:id' do
  @message = Message.find(params[:id].to_i)
  @comment = Comment.new(message_id: @message.id)

  erb :show
end

get '/edit/:id' do
  access_danied unless current_user
  @message = Message.find(params[:id].to_i)

  erb :edit
end

get '/delete/:id' do
  access_danied unless  current_user
  Message.find(params[:id].to_i).destroy
  redirect('/')
end

get '/login' do
  @user_errors = User.new

  erb :login
end

get '/logout' do
  session[:id] = nil
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

  binding.pry
  if user = User.authenticate(params[:nickname], params[:password])
    session[:id] = user.id
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

helpers do
  def current_user
    User.find_by(id: session[:id])
  end
end
