require 'test_helper'

class FormulasTest < ActiveSupport::TestCase

  test "fahrenheit to celsius" do
    assert_equal -21, Formulas.fahrenheit_to_celsius(-5)
    assert_equal -12, Formulas.fahrenheit_to_celsius(10)
    assert_equal   0, Formulas.fahrenheit_to_celsius(32)
    assert_equal  24, Formulas.fahrenheit_to_celsius(75)
  end
end