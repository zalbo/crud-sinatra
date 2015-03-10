require 'sinatra'
require 'active_record'
require 'sqlite3'
require 'logger'
require 'shotgun'
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
      t.text :message
    end
  end
end

ActiveRecord::Migrator.migrate CreateMessageMigration

begin
  CreateMessageMigration.new.migrate(:up)
rescue ActiveRecord::StatementInvalid
  puts "table messages already exists"
end

class Message < ActiveRecord::Base
  validates_presence_of :message
  validates :email, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }
end

get '/' do
  @messages = Message.all
  erb :index
end

get '/new' do
  erb :new
end

get '/show/:id' do
  @message = Message.find(params[:id].to_i)
  erb :show
end

get '/edit/:id' do
  @message = Message.find(params[:id].to_i)
  erb :edit
end

get '/delete/:id' do
  Message.find(params[:id].to_i).destroy
  redirect('/')
end

post '/' do
  Message.create({ :message => params[:message].strip , :email => params[:email]})
  @messages = Message.all
  binding.pry
  erb :index
end

post '/edit/:id' do
  @messages = Message.all()
  Message.update(params[:id].to_i, :message => params[:message].strip , :email => params[:email])
  erb :index
end
