
require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'sinatra'
require 'sqlite3'
require 'logger'
require 'pry'
require 'encrypted_cookie'
require 'rdiscount'
require_relative 'config'
require_relative 'migration'
require_relative 'models'

get '/' do

  session[:search] = nil if params[:search] == ""
  params[:search] = session[:search] if session[:search] && params[:search].nil?

  if params[:search]
    @articles = Article.search(params[:search])
    session[:search] = params[:search]
  else
    @articles = Article.all
  end
  erb :index
end

get '/new' do
  access_danied unless current_user
  @article = Article.new

  erb :new
end

get '/show/:id' do
  @article = Article.find(params[:id].to_i)
  @comment = Comment.new(article_id: @article.id)

  File.open(@article.image, "r")
  erb :show
end

get '/edit/:id' do
  access_danied unless current_user
  @article = Article.find(params[:id].to_i)

  erb :edit
end

get '/delete/:id' do
  access_danied unless  current_user
  Article.find(params[:id].to_i).destroy
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

  File.open(params[:image][:filename], "w") do |f|
    f.write(params[:image][:tempfile].read)
  end
  @article = Article.new(content: RDiscount.new(params[:content]).to_html, title: params[:title] , image: params[:image][:filename])

  if @article.save
    redirect('/')
  else
    erb :new
  end
end

post '/edit/:id' do

  @article = Article.find(params[:id].to_i)

  if @article.update(content: RDiscount.new(params[:content]).to_html, title: params[:title])
    redirect('/')
  else
    erb :edit
  end
end

post '/comment' do

  @article = Article.find(params[:article_id].to_i)
  @comment = @article.comments.build

  if @comment.update(aricle_params(params))
    redirect("/show/#{@article.id}")
  else
    erb :show
  end
end

post '/login' do

  if user = User.authenticate(params[:nickname], params[:password])
    session[:id] = user.id
    redirect('/')
  else
    @user_errors = User.create(params)
    erb :login
  end
end

def aricle_params(params)
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
