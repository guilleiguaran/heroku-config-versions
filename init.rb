require "versions/heroku/command/config"

begin
  require "heroku-api"
rescue LoadError
  puts <<-MSG
  heroku-config-versions - requires the heroku-api gem. Please install:

  gem install heroku-api
  MSG
  exit
end

if RUBY_VERSION < "2.0.0"
  puts "heroku-config-versions - requires Ruby 2.0 or greater."
  exit
end
