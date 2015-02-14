class ContextTest < Minitest::Test
  def test_require_string
    context = ConfigVar::Context.new
    context.required_string(:database_url)
    context.reload(database_url: 'postgres:///test')
    assert_equal('postgres:///test', context.database_url)
  end
end
