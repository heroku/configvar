require 'helper'

class ConfigVarTest < Minitest::Test
  include EnvironmentHelper

  # ConfigVar.define takes a block that defines required and optional
  # configuration variables, loads values for those variables from the
  # environment, and returns a collection that can be used to retrieve loaded
  # values.
  def test_define
    set_env('DATABASE_URL', 'postgres:///example')
    set_env('PORT', '8080')
    set_env('ENABLED', '1')
    config = ConfigVar.define do
      required_string :database_url
      required_int    :port
      required_bool   :enabled
      optional_string :name,    'Bob'
      optional_int    :age,     42
      optional_bool   :balding, true
    end
    assert_equal('postgres:///example', config[:database_url])
    assert_equal(8080, config[:port])
    assert_equal(true, config[:enabled])
    assert_equal('Bob', config[:name])
    assert_equal(42, config[:age])
    assert_equal(true, config[:balding])
  end
end

