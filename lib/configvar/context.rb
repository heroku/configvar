module ConfigVar
  class Context
    def initialize
      @required = {}
      @optional = {}
      @values = {}
    end

    def reload(env)
      @values = {}
      @required.each_value do |function|
        @values.merge!(function.call(env))
      end
    end

    def method_missing(name, *args)
      value = @values[name]
      if value.nil?
        address = "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
        raise NoMethodError.new("undefined method `#{name}' for ##{address}")
      end
      value
    end

    def required_string(name)
      @required[name] = lambda do |env|
        if value = env[name]
          {name => value}
        else
          raise MissingConfig.new(name)
        end
      end
    end
  end
end
