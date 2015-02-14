module ConfigVar
  class Context
    def initialize
      @definitions = {}
      @values = {}
    end

    def reload(env)
      @values = {}
      @definitions.each_value do |function|
        @values.merge!(function.call(env))
      end
    end

    def [](name)
      value = @values[name]
      if value.nil?
        raise NameError.new("No value available for #{name}")
      end
      value
    end

    def required_string(name)
      required_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => value}
        else
          raise MissingConfig.new(name)
        end
      end
    end

    def required_int(name)
      required_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => Integer(value)}
        else
          raise MissingConfig.new(name)
        end
      end
    end

    def required_bool(name)
      required_custom(name) do |env|
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

    def required_custom(name, &blk)
      @definitions[name] = blk
    end

    def optional_string(name, default)
      optional_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => value}
        else
          {name => default}
        end
      end
    end

    def optional_int(name, default)
      optional_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => Integer(value)}
        else
          {name => default}
        end
      end
    end

    def optional_bool(name, default)
      optional_custom(name) do |env|
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
          {name => default}
        end
      end
    end

    def optional_custom(name, &blk)
      @definitions[name] = blk
    end
  end
end
