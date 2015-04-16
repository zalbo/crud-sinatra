require_relative './create_email_env.rb'

use Rack::Session::EncryptedCookie,
:secret => "TYPE_YOUR_LONG_RANDOM_STRING_HERE"



ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
:adapter => 'sqlite3',
:database => 'zalbo.db'
)


unless File.exist?('.env')
  File.new(".env", "w")
  puts "file .env create"
  create_email
end

require_env

if (ENV['SITE_EMAIL'] == nil) || (ENV['PASSWORD_EMAIL']) == nil
  File.new(".env", "w")
  puts "file .env create"
  create_email
else
  puts "correct .env"
end
