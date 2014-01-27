require 'spec_helper'
require 'sqlite3'
require 'active_record'
require 'database_cleaner'

db_dir = File.join(File.expand_path(__dir__ ), "acceptance/db/")

ActiveRecord::Base.establish_connection({
  pool: 5,
  timeout: 5000,
  database: "#{db_dir}/development.sqlite3",
  adapter: "sqlite3"
})

ActiveRecord::Migrator.migrate "#{db_dir}/migrate"

Dir[File.join(File.expand_path(__dir__ ), "acceptance/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end