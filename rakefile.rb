require 'faker'
require_relative './controller.rb'

def require_env
  require 'dotenv'
  Dotenv.load
  require 'net/smtp'
end

def create_email
  require_env

  File.new(".env", "w")
  puts "file .env create"
  puts "insert your email (only gmail)"
  email = gets.chomp
  puts "insert password email "
  password = gets.chomp
  puts "confirm password"
  conf_password = gets.chomp
  if password == conf_password

    file = File.open(".env", 'w')
    file << """export SITE_EMAIL=#{email}
export PASSWORD_EMAIL=#{password}"""
    file.close

    begin
      require_env
      message = <<EOF
Subject: Text Email
Email and pass correct
EOF

      smtp = Net::SMTP.new 'smtp.gmail.com', 587
      smtp.enable_starttls
      smtp.start('gmail.com', ENV['SITE_EMAIL'], ENV['PASSWORD_EMAIL'], :login)
      smtp.send_message message, ENV['SITE_EMAIL'] ,  ENV['SITE_EMAIL']
      smtp.finish
      puts "Email ok"
    rescue Net::SMTPAuthenticationError
      puts "Email or pass incorrect"
    rescue Net::SMTPFatalError
      puts "Email or pass incorrect"
    end
  else
      puts "error password"
  end
end


namespace :db do

  desc "Create default user"
  task :create_default_user do
    puts "nickname?"
    nickname = STDIN.gets.chomp
    puts "password?"
    password = STDIN.gets.chomp
    puts "rewrite password?"
    password_confirm = STDIN.gets.chomp

    if password == password_confirm
      User.create(nickname: nickname, password: password)
      puts "Add user ##COMPLETE##"
    else
      puts "password does not match "
      puts "Add user ##DON'T COMPLETE##"
    end
  end

  desc "Create fake articles"
  task :create_fake_articles do
    puts "how many articles fake do you want create?"
    num = STDIN.gets.chomp.to_i


    num.times  do |x|
      fake_name = Faker::Name.name
      fake_string = Faker::Lorem.sentence(3, true)
      Article.create(title: fake_name, content: fake_string)
    end
  end

  desc "Create fake comments"
  task :create_fake_comments do

    Article.all.each do |a|
      puts "N.ID #{a.id} || #{a.title}"
    end
    puts "insert number id of article do you want insert comments"
    id = STDIN.gets.chomp
    puts "how many comments fake do you want create?"
    num = STDIN.gets.chomp.to_i

    num.times  do  |x|
      article = Article.find(id.to_i)
      comment = article.comments.build
      fake_email = Faker::Internet.email
      fake_string = Faker::Lorem.sentence(3, true)
      comment.update(email: fake_email , content: fake_string )

    end
  end

  desc "Delete all articles"
  task :delete_all_articles do
    Article.destroy_all
    puts "DONE!"
  end

  desc "Delete users"
  task :delete_users do
    User.all.each do |u|
      puts "N.ID #{u.id} || #{u.nickname}"
    end
    puts "do you want delete all USERS or delete one USER?[all/N.id USER]"
    ask = STDIN.gets.chomp.to_s

    if ask == "all"
      User.destroy_all
      puts "DONE!"
    else
      User.find(ask).destroy
      puts "DONE!"
    end
  end

  desc "Delete comments"
  task :delete_comments do
    Article.all.each do |a|
      puts "N.ID #{a.id} || #{a.title}"
    end
    puts "do you want delete all comments of all article or delete all coments for single article?[all/N.id article]"
    ask = STDIN.gets.chomp.to_s

    if ask == "all"
      Comment.destroy_all
      puts "DONE!"
    else
      article = Article.find(ask)
      article.comments.destroy_all
      puts "DONE!"
    end
  end
end

namespace :env do
  desc "delete env"
  task :delete_env do
    File.delete(".env")
  end
end
