class ContextTest < Minitest::Test
  # Context.reload loads required strings.
  def test_reload_require_string
    context = ConfigVar::Context.new
    context.require_string :database_url
    context.reload('DATABASE_URL' => 'postgres:///test')
    assert_equal('postgres:///test', context.database_url)
  end

  # Context.reload raises a MissingConfig if no value is provided for a
  # required string value.
  def test_reload_require_string_without_value
    context = ConfigVar::Context.new
    context.require_string :database_url
    assert_raises ConfigVar::MissingConfig do
      context.reload({})
    end
  end

  # Context.reload loads required integers.
  def test_reload_require_int
    context = ConfigVar::Context.new
    context.require_int :port
    context.reload('PORT' => '8080')
    assert_equal(8080, context.port)
  end

  # Context.reload raises an ArgumentError if a non-int value is provided for
  # a required integer value.
  def test_reload_require_int_with_malformed_value
    context = ConfigVar::Context.new
    context.require_int :port
    assert_raises ArgumentError do
      context.reload('PORT' => 'eight zero 8 zero')
    end
  end

  # Context.reload raises a MissingConfig if no value is provided for a
  # required integer value.
  def test_reload_require_int_without_value
    context = ConfigVar::Context.new
    context.require_int :port
    assert_raises ConfigVar::MissingConfig do
      context.reload({})
    end
  end

  # Context.reload loads required booleans.
  def test_reload_require_bool
    context = ConfigVar::Context.new
    context.require_bool :value_1
    context.require_bool :value_true
    context.require_bool :value_0
    context.require_bool :value_false
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
  def test_reload_require_int_with_malformed_value
    context = ConfigVar::Context.new
    context.require_bool :value
    assert_raises ArgumentError do
      context.reload('VALUE' => 'malformed')
    end
  end

  # Context.reload raises a MissingConfig if no value is provided for a
  # required boolean value.
  def test_reload_require_bool_without_value
    context = ConfigVar::Context.new
    context.require_bool :value
    assert_raises ConfigVar::MissingConfig do
      context.reload({})
    end
  end
end
