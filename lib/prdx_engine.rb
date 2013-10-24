if RUBY_VERSION < '1.9'
  raise LoadError, "Ruby 1.9 or newer is required to load this file due to ordered Hash feature usage"
end

require_relative 'prdx_engine/version'
require_relative 'prdx_engine/sav_parser'
# allow missing compiled version, use slower Ruby parsing instead
begin
  require_relative 'ext/prdx_engine'
rescue LoadError
end

module PrdxEngine
  # Your code goes here...
end
