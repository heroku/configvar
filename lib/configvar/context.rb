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

    def require_string(name)
      require_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => value}
        else
          raise MissingConfig.new(name)
        end
      end
    end

    def require_int(name)
      require_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => Integer(value)}
        else
          raise MissingConfig.new(name)
        end
      end
    end

    def require_bool(name)
      require_custom(name) do |env|
        if value = env[name.to_s.upcase]
          if ['1', 'true'].include?(value.downcase)
            value = true
          elsif ['0', 'false'].include?(value.downcase)
            value = false
          else
            raise ArgumentError.new("#{value} is not a valid boolean")
          end
          {name => value}
        else
          raise MissingConfig.new(name)
        end
      end
    end

    def require_custom(name, &blk)
      @required[name] = blk
    end
  end
end
