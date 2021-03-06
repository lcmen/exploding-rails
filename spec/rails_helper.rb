# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  def db
    Sequel::DATABASES.first
  end

  def migratiions_must_be_run
    raise "Migrations need to be run. Execute: `rails db:migrate`"
  end

  config.before(:all) do
    migrations = db[:schema_migrations].order(Sequel.desc(:filename))
    migratiions_must_be_run! if migrations.empty?

    db_last_migration = migrations.first[:filename]
    file_last_migration = File.basename(Dir["#{Rails.root}/db/migrate/*"].sort.last)
    migratiions_must_be_run if db_last_migration != file_last_migration
  end

  config.before do
    tables = db.tables - [:schema_migrations]
    db[*tables].truncate
  end

  config.use_active_record = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
