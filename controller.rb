require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'sinatra'
require 'sqlite3'
require 'logger'
require 'pry'
require 'encrypted_cookie'
require 'rdiscount'
require 'carrierwave/sequel'
require 'carrierwave/orm/activerecord'
require 'kaminari/sinatra'
require_relative 'config'
require_relative 'migration'
require_relative 'models'

get '/' do
  session[:page] = 1
  @n_article = 0

  if session[:page_count] == nil
    params[:page_count] = 5
    session[:page_count] = params[:page_count]
  else
    params[:page_count] = session[:page_count]
  end

  if params[:search] != nil
    session[:search] = params[:search]
  else
    params[:search] = session[:search]
    session = nil
  end

  @articles = Article.search(params[:search]).page(1).per(params[:page_count])

  layout = true
  if params[:layout] == "none"
    layout = true
  end

  erb :index, layout: layout
end

get '/page/:page' do
  if params[:page].to_i == 1
    redirect ('/')
  end
  session[:page] = params[:page].to_i

  @n_article = (session[:page_count] * params[:page].to_i) - session[:page_count]

  @articles = Article.search(session[:search]).page(params[:page]).per(session[:page_count])

  layout = true
  if params[:layout] == "none"
    layout = true
  end

  erb :index, layout: layout
end

get '/new' do
  access_denied unless current_user
  @article = Article.new
  erb :new
end

get '/show/:id' do
  @article = Article.find(params[:id].to_i)
  @comment = Comment.new(article_id: @article.id)
  erb :show
end

get '/edit/:id' do
  access_denied unless current_user
  @article = Article.find(params[:id].to_i)
  erb :edit
end

get '/delete/:id' do
  access_denied unless  current_user
  Article.find(params[:id].to_i).destroy
  if session[:page] == 1
    redirect('/')
  else
    redirect("/page/#{session[:page]}")
  end
end

get '/delete_comment/:id/:a_id' do
  access_denied unless  current_user
  Comment.find(params[:id].to_i).destroy
  redirect("/show/#{params[:a_id].to_i}")
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

  @article = Article.new(content: params[:content], title: params[:title], image: params[:image])

  if @article.save
    redirect('/')
  else
    erb :new
  end
end

post '/formatpage'do
session[:page_count] = params[:page_count].to_i
redirect ('/')
end

post '/edit/:id' do
  @article = Article.find(params[:id].to_i)

  delete_img = params.delete("delete_img")
  if delete_img
    @article.image.remove!
    @article[:image] = nil
  end

  if @article.update(article_params(params))
    redirect('/')
  else
    erb :edit
  end
end

post '/comment' do
  @article = Article.find(params[:article_id].to_i)
  @comment = @article.comments.build

  if @comment.update(article_params(params))
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

def article_params(params)
  params.delete('splat')
  params.delete('capture')
  params.delete('captures')
  params.delete('delete_img')
  params
end

def access_denied
  halt 403, erb(:error)
end

helpers do
  def current_user
    User.find_by(id: session[:id])
  end
end
