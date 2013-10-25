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
