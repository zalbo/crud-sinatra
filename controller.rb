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

get '/delete_comment/:id/:a_id' do
  access_danied unless  current_user
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

    a = Article.new
    a.image = params[:image]



    @article = Article.new(content: params[:content], title: params[:title] , image: a.image.url )
    binding.pry

    if @article.save
      redirect('/')
    else
      erb :new
    end

end

post '/edit/:id' do
  @article = Article.find(params[:id].to_i)

  if @article.update(content: params[:content], title: params[:title])
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
