def require_env
  require 'dotenv'
  Dotenv.load
  require 'net/smtp'
end

def create_email
  require_env

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
