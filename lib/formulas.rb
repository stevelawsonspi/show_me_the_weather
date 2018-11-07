module Formulas
  module_function # methods in this module can be called directly. eg. Formulas.method_name
  
  def fahrenheit_to_celsius(fahrenheit)
    celsius = ((fahrenheit - 32) * 5.0 / 9.0).round
  end

end
