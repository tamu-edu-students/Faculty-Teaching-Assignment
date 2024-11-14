# frozen_string_literal: true

# features/support/hooks.rb for Cucumber
Before do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
