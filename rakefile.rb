require 'faker'
require_relative './controller.rb'


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
