module ConfigVar
  class Context
    def initialize
      @definitions = {}
      @values = {}
    end

    # Reload the environment from a Hash of available environment values.
    def reload(env)
      @values = {}
      @definitions.each_value do |function|
        @values.merge!(function.call(env))
      end
    end

    # Fetch a configuration value.  The name must be a lowercase version of an
    # uppercase name defined in the environment.  A NoMethodError is raised if
    # no value matching the specified name is available.
    def method_missing(name, *args)
      value = @values[name]
      if value.nil? && !@values.has_key?(name)
        address = "<#{self.class.name}:0x00#{(self.object_id << 1).to_s(16)}>"
        raise NoMethodError.new("undefined method `#{name}' for ##{address}")
      end
      value
    end

    # Define a required string config var.
    def required_string(name)
      required_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => value}
        else
          raise ConfigError.new("A value must be provided for #{name.to_s.upcase}")
        end
      end
    end

    # Define a required integer config var.
    def required_int(name)
      required_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => parse_int(name, value)}
        else
          raise ConfigError.new("A value must be provided for #{name.to_s.upcase}")
        end
      end
    end

    # Define a required boolean config var.
    def required_bool(name)
      required_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => parse_bool(name, value)}
        else
          raise ConfigError.new("A value must be provided for #{name.to_s.upcase}")
        end
      end
    end

    # Define a required custom config var.  The block must take the
    # environment as a parameter, load and process values from the it, and
    # return a hash that will be merged into the collection of all config
    # vars.  If a required value is not found in the environment the block
    # must raise a ConfigVar::ConfigError exception.
    def required_custom(name, &blk)
      define_config(name, &blk)
    end

    # Define a required string config var with a default value.
    def optional_string(name, default)
      optional_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => value}
        else
          {name => default}
        end
      end
    end

    # Define a required integer config var with a default value.
    def optional_int(name, default)
      optional_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => parse_int(name, value)}
        else
          {name => default}
        end
      end
    end

    # Define a required boolean config var with a default value.
    def optional_bool(name, default)
      optional_custom(name) do |env|
        if value = env[name.to_s.upcase]
          {name => parse_bool(name, value)}
        else
          {name => default}
        end
      end
    end

    # Define a required custom config var.  The block must take the
    # environment as a parameter, load and process values from the it, and
    # return a hash that will be merged into the collection of all config
    # vars.
    def optional_custom(name, &blk)
      define_config(name, &blk)
    end

    private

    # Convert a string to an integer.  An ArgumentError is raised if the
    # string is not a valid integer.
    def parse_int(name, value)
      Integer(value)
    rescue ArgumentError
      raise ArgumentError.new("#{value} is not a valid boolean for #{name.to_s.upcase}")
    end

    # Convert a string to boolean.  An ArgumentError is raised if the string
    # is not a valid boolean.
    def parse_bool(name, value)
      if ['1', 'true'].include?(value.downcase)
        true
      elsif ['0', 'false'].include?(value.downcase)
        false
      else
        raise ArgumentError.new("#{value} is not a valid boolean for #{name.to_s.upcase}")
      end
    end

    # Define a handler for a configuration value.
    def define_config(name, &blk)
      if @definitions.has_key?(name)
        raise ConfigError.new("#{name.to_s.upcase} is already registered")
      end
      @definitions[name] = Proc.new do |env|
        value = yield env
        if value.kind_of?(Hash)
          value
        else
          {name => value}
        end
      end
    end
  end
end
