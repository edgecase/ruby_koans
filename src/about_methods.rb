require File.expand_path(File.dirname(__FILE__) + '/neo')

def my_global_method(a,b)
  a + b
end

class AboutMethods < Neo::Koan

  def test_calling_global_methods
    assert_equal __(5), my_global_method(2,3)
  end

  def test_calling_global_methods_without_parentheses
    result = my_global_method 2, 3
    assert_equal __(5), result
  end

  # (NOTE: We are using eval below because the example code is
  # considered to be syntactically invalid).
  def test_sometimes_missing_parentheses_are_ambiguous
    #--
    eval "assert_equal 5, my_global_method(2, 3)" # REMOVE CHECK # __
    if false
      #++
    eval "assert_equal 5, my_global_method 2, 3" # ENABLE CHECK # __
      #--
    end
    #++
    #
    # Ruby doesn't know if you mean:
    #
    #   assert_equal(5, my_global_method(2), 3)
    # or
    #   assert_equal(5, my_global_method 2, 3))
    #
    # Rewrite the eval string to continue.
    #
  end

  # NOTE: wrong number of arguments is not a SYNTAX error, but a
  # runtime error.
  def test_calling_global_methods_with_wrong_number_of_arguments
    exception = assert_raise(___(ArgumentError)) do
      my_global_method
    end
    #--
    pattern = "wrong (number|#) of arguments"
    #++
    assert_match(/#{__(pattern)}/, exception.message)

    exception = assert_raise(___(ArgumentError)) do
      my_global_method(1,2,3)
    end
    assert_match(/#{__(pattern)}/, exception.message)
  end

  # ------------------------------------------------------------------

  def method_with_defaults(a, b=:default_value)
    [a, b]
  end

  def test_calling_with_default_values
    assert_equal [1, __(:default_value)], method_with_defaults(1)
    assert_equal [1, __(2)], method_with_defaults(1, 2)
  end

  # ------------------------------------------------------------------

  def method_with_var_args(*args)
    args
  end

  def test_calling_with_variable_arguments
    assert_equal __(Array), method_with_var_args.class
    assert_equal __([]), method_with_var_args
    assert_equal __([:one]), method_with_var_args(:one)
    assert_equal __([:one, :two]), method_with_var_args(:one, :two)
  end

  # ------------------------------------------------------------------

  def method_with_explicit_return
    :a_non_return_value
    return :return_value
    :another_non_return_value
  end

  def test_method_with_explicit_return
    assert_equal __(:return_value), method_with_explicit_return
  end

  # ------------------------------------------------------------------

  def method_without_explicit_return
    :a_non_return_value
    :return_value
  end

  def test_method_without_explicit_return
    assert_equal __(:return_value), method_without_explicit_return
  end

  # ------------------------------------------------------------------

  def my_method_in_the_same_class(a, b)
    a * b
  end

  def test_calling_methods_in_same_class
    assert_equal __(12), my_method_in_the_same_class(3,4)
  end

  def test_calling_methods_in_same_class_with_explicit_receiver
    assert_equal __(12), self.my_method_in_the_same_class(3,4)
  end

  # ------------------------------------------------------------------

  def my_private_method
    "a secret"
  end
  private :my_private_method

  def test_calling_private_methods_without_receiver
    assert_equal __("a secret"), my_private_method
  end

  def test_calling_private_methods_with_an_explicit_receiver
    exception = assert_raise(___(NoMethodError)) do
      self.my_private_method
    end
    assert_match /#{__("method `my_private_method'")}/, exception.message
  end

  # ------------------------------------------------------------------

  class Dog
    def name
      "Fido"
    end

    private

    def tail
      "tail"
    end
  end

  def test_calling_methods_in_other_objects_require_explicit_receiver
    rover = Dog.new
    assert_equal __("Fido"), rover.name
  end

  def test_calling_private_methods_in_other_objects
    rover = Dog.new
    assert_raise(___(NoMethodError)) do
      rover.tail
    end
  end
end
