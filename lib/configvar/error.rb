module ConfigVar
  class MissingConfig < StandardError
    def initialize(name)
      super("A value must be provided for #{name.to_s.upcase}.")
    end
  end
end
