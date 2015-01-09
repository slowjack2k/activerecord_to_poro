require 'active_record'

db_dir = File.join(File.expand_path(__dir__ ), "ar_support/db/")
# ENV['DATABASE_URL']="sqlite3://localhost/:memory:?pool=5&timeout=5000"

con_settings = {
    pool: 5,
    timeout: 5000,
    database: ":memory:",
    adapter: "sqlite3"
}

# con_settings = {
#     adapter: 'postgresql',
#     encoding: 'utf8',
#     pool: 5,
#     host: 'localhost',
#     port: 5000,
#     database: 'poro_test'
# }

require 'database_cleaner'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(con_settings)
ActiveRecord::Migrator.migrate "#{db_dir}/migrate"

Dir[File.join(File.expand_path(__dir__ ), "ar_support/models/**/*.rb")].each { |f| require f }

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation, {:except => %w[schema_migrations public.schema_migrations]}
    DatabaseCleaner.clean_with(:truncation, {:except => %w[schema_migrations public.schema_migrations]})
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end