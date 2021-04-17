# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'
require 'vcr'

# Add files that you want to ignore for coverage purposes to this array
ignored_coverage_files = []

RSpec.configure do |config|
  # config.before do
  #   stub_feature_default
  # end

  SimpleCov.minimum_coverage 80
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                   SimpleCov::Formatter::HTMLFormatter,
                                                                   SimpleCov::Formatter::Console

                                                                 ])

  SimpleCov.start 'rails' do
    ignored_coverage_files.each { |file| add_filter(file) }

    add_filter 'app/admin'
    add_filter 'app/uploaders'
  end
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
  Kernel.srand config.seed
end
