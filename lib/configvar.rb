module ConfigVar
  # Define required and optional configuration variables and load them from
  # the environment.  Returns a configuration object that can be treated like
  # a Hash with values available using lowercase symbols.  For example, a PORT
  # value from the environment can be accesses as config[:port] in the
  # returned object.  Booleans are only considered valid if they are one of
  # '0', '1', 'true' or 'false'.  The values are case insensitive, so 'TRUE'
  # is also a valid boolean.
  #
  # Example:
  #
  #   config = ConfigVar.define do
  #     required_string  :database_url
  #     required_int     :port
  #     required_bool    :enabled
  #     optional_string  :name,         'Bob'
  #     optional_int     :age,          42
  #     optional_bool    :friendly,     true
  #   end
  def self.define(&blk)
    context = ConfigVar::Context.new
    context.instance_eval(&blk)
    context.reload(ENV)
    context
  end
end

require 'configvar/context'
require 'configvar/error'
require 'configvar/version'
