use Rack::Session::EncryptedCookie,
:secret => "TYPE_YOUR_LONG_RANDOM_STRING_HERE"


ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
:adapter => 'sqlite3',
:database => 'zalbo.db'
)
