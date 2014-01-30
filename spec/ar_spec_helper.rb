require 'active_record'
require 'database_cleaner'

db_dir = File.join(File.expand_path(__dir__ ), "ar_support/db/")
# ENV['DATABASE_URL']="sqlite3://localhost/:memory:?pool=5&timeout=5000"



ActiveRecord::Base.establish_connection({
                                            pool: 5,
                                            timeout: 5000,
                                            database: ":memory:",
                                            adapter: "sqlite3"
                                        })

ActiveRecord::Migrator.migrate "#{db_dir}/migrate"

Dir[File.join(File.expand_path(__dir__ ), "ar_support/models/**/*.rb")].each { |f| require f }

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