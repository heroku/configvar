module ConfigVar
  def self.define(&blk)
    context = ConfigVar::Context.new
    context.instance_eval(blk)
    context.reload
    context
  end
end

require 'configvar/context'
require 'configvar/version'
