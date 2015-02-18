class ContextTest < Minitest::Test
  # Context.<name> raises a NoMethodError if an unknown configuration value is
  # requested.
  def test_index_unknown_value
    context = ConfigVar::Context.new
    error = assert_raises NoMethodError do
      context.unknown
    end
    assert_match(
      /undefined method `unknown' for #<ConfigVar::Context:0x[0-9a-f]*>/,
      error.message)
  end

  # Context.reload loads required string values.
  def test_reload_required_string
    context = ConfigVar::Context.new
    context.required_string :database_url
    context.reload('DATABASE_URL' => 'postgres:///test')
    assert_equal('postgres:///test', context.database_url)
  end

  # Context.reload raises a ConfigError if no value is provided for a required
  # string value.
  def test_reload_required_string_without_value
    context = ConfigVar::Context.new
    context.required_string :database_url
    error = assert_raises ConfigVar::ConfigError do
      context.reload({})
    end
    assert_equal('A value must be provided for DATABASE_URL', error.message)
  end

  # Context.reload loads required integer values.
  def test_reload_required_int
    context = ConfigVar::Context.new
    context.required_int :port
    context.reload('PORT' => '8080')
    assert_equal(8080, context.port)
  end

  # Context.reload raises an ArgumentError if a non-int value is provided for
  # a required integer value.
  def test_reload_required_int_with_malformed_value
    context = ConfigVar::Context.new
    context.required_int :port
    error = assert_raises ArgumentError do
      context.reload('PORT' => 'eight zero 8 zero')
    end
    assert_equal('eight zero 8 zero is not a valid boolean for PORT',
                 error.message)
  end

  # Context.reload raises a ConfigError if no value is provided for a required
  # integer value.
  def test_reload_required_int_without_value
    context = ConfigVar::Context.new
    context.required_int :port
    error = assert_raises ConfigVar::ConfigError do
      context.reload({})
    end
    assert_equal('A value must be provided for PORT', error.message)
  end

  # Context.reload loads required boolean values.
  def test_reload_required_bool
    context = ConfigVar::Context.new
    context.required_bool :value_1
    context.required_bool :value_true
    context.required_bool :value_0
    context.required_bool :value_false
    context.reload('VALUE_1' => '1', 'VALUE_TRUE' => 'True',
                   'VALUE_0' => '0', 'VALUE_FALSE' => 'False')
    assert_equal(true, context.value_1)
    assert_equal(true, context.value_true)
    assert_equal(false, context.value_0)
    assert_equal(false, context.value_false)
  end

  # Context.reload raises an ArgumentError if a non-bool value is provided for
  # a required boolean value.  Only case insensitive versions of '1', 'true',
  # '0' and 'false' are permitted.
  def test_reload_required_bool_with_malformed_value
    context = ConfigVar::Context.new
    context.required_bool :value
    error = assert_raises ArgumentError do
      context.reload('VALUE' => 'malformed')
    end
    assert_equal('malformed is not a valid boolean for VALUE', error.message)
  end

  # Context.reload raises a ConfigError if no value is provided for a required
  # boolean value.
  def test_reload_required_bool_without_value
    context = ConfigVar::Context.new
    context.required_bool :value
    error = assert_raises ConfigVar::ConfigError do
      context.reload({})
    end
    assert_equal('A value must be provided for VALUE', error.message)
  end

  # Context.reload makes all values returned from the custom block used to
  # process a required value available via the collection interface.
  def test_reload_required_custom
    context = ConfigVar::Context.new
    context.required_custom :name do |env|
      {greeting: 'Hello', name: 'Bob', age: 42}
    end
    context.reload({})
    assert_equal('Hello', context.greeting)
    assert_equal('Bob', context.name)
    assert_equal(42, context.age)
  end

  # Context.reload loads optional string values.
  def test_reload_optional_string
    context = ConfigVar::Context.new
    context.optional_string :database_url, 'postgres:///default'
    context.reload('DATABASE_URL' => 'postgres:///test')
    assert_equal('postgres:///test', context.database_url)
  end

  # Context.reload loads optional string values.
  def test_reload_optional_string_without_value
    context = ConfigVar::Context.new
    context.optional_string :database_url, 'postgres:///default'
    context.reload({})
    assert_equal('postgres:///default', context.database_url)
  end

  # Context.reload loads optional integer values.
  def test_reload_optional_int
    context = ConfigVar::Context.new
    context.optional_int :port, 8080
    context.reload('PORT' => '8081')
    assert_equal(8081, context.port)
  end

  # Context.reload loads optional integer values.
  def test_reload_optional_int_without_value
    context = ConfigVar::Context.new
    context.optional_int :port, 8080
    context.reload({})
    assert_equal(8080, context.port)
  end

  # Context.reload loads optional boolean values.
  def test_reload_optional_bool
    context = ConfigVar::Context.new
    context.optional_bool :value_1, false
    context.optional_bool :value_true, false
    context.optional_bool :value_0, true
    context.optional_bool :value_false, true
    context.reload('VALUE_1' => '1', 'VALUE_TRUE' => 'True',
                   'VALUE_0' => '0', 'VALUE_FALSE' => 'False')
    assert_equal(true, context.value_1)
    assert_equal(true, context.value_true)
    assert_equal(false, context.value_0)
    assert_equal(false, context.value_false)
  end

  # Context.reload loads optional boolean values.
  def test_reload_optional_bool_without_value
    context = ConfigVar::Context.new
    context.optional_bool :value_1, false
    context.optional_bool :value_true, false
    context.optional_bool :value_0, true
    context.optional_bool :value_false, true
    context.reload({})
    assert_equal(false, context.value_1)
    assert_equal(false, context.value_true)
    assert_equal(true, context.value_0)
    assert_equal(true, context.value_false)
  end

  # Context.reload correctly handles a nil default value for an optional
  # variable.
  def test_reload_optional_value_with_nil_default
    context = ConfigVar::Context.new
    context.optional_int :port, nil
    context.reload({})
    assert_nil(context.port)
  end

  # Context.reload makes all values returned from the custom block used to
  # process an optional value available via the collection interface.
  def test_reload_optional_custom
    context = ConfigVar::Context.new
    context.optional_custom :name do |env|
      {greeting: 'Hello', name: 'Bob', age: 42}
    end
    context.reload({})
    assert_equal('Hello', context.greeting)
    assert_equal('Bob', context.name)
    assert_equal(42, context.age)
  end

  # Context.reload reinitialized loaded values from the provided environment.
  def test_reload
    context = ConfigVar::Context.new
    context.optional_int :port, 8080
    context.reload('PORT' => '8081')
    assert_equal(8081, context.port)
    context.reload('PORT' => '9000')
    assert_equal(9000, context.port)
  end

  # Context.required_* and Context.optional_* methods raise a ConfigError if
  # the same name is defined twice.
  def test_register_duplicate_config
    context = ConfigVar::Context.new
    context.required_int :port
    error = assert_raises ConfigVar::ConfigError do
      context.optional_int :port, 8080
    end
    assert_equal('PORT is already registered', error.message)
  end

  # Context.required_uri parses URIs into their component parts.
  def test_required_uri
    context = ConfigVar::Context.new
    context.required_uri :testing_url

    url = 'http://username:password@example.com/testing'
    context.reload('TESTING_URL' => url)

    assert_equal('example.com', context.testing_url_host)
    assert_equal('testing', context.testing_url_path)
    assert_equal('http', context.testing_url_scheme)
    assert_equal(url, context.testing_url)
    assert_equal('username:password', context.testing_url_credentials)
  end

  # Context.require_uri parseis URIs into their component parts takes an
  # optional prefix for the components.
  def test_required_uri_with_prefix
    context = ConfigVar::Context.new
    context.required_uri :testing_url, 'prefix'

    url = 'http://username:password@example.com/testing'
    context.reload('TESTING_URL' => url)

    assert_equal(url, context.testing_url)
    assert_equal('example.com', context.prefix_host)
    assert_equal('testing', context.prefix_path)
    assert_equal('http', context.prefix_scheme)
    assert_equal('username:password', context.prefix_credentials)
  end

  # Context.required_uri throws an appropriate error if it's an invalid URI.
  def test_required_uri_with_invalid_uri
    context = ConfigVar::Context.new
    context.required_uri :testing_url

    url = 'http:\/#'
    assert_raises ArgumentError do
      context.reload('TESTING_URL' => url)
    end
  end

end
