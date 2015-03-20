class CreateArticleMigration < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.text :content
      t.text :title
      t.text :image
    end
  end
end

class CreateCommentMigration < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :article_id
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

[CreateArticleMigration, CreateCommentMigration, CreateUserMigration].each do |migration|

  ActiveRecord::Migrator.migrate migration

  begin
    migration.new.migrate(:up)
  rescue ActiveRecord::StatementInvalid
    puts "#{migration}: table already exists"
  end
end
