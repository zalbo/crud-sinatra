
  use Rack::Session::EncryptedCookie,
  :secret => "TYPE_YOUR_LONG_RANDOM_STRING_HERE"


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
