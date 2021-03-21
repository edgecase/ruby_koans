require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutScope < Neo::Koan
  module Jims
    class Dog
      def identify
        :jims_dog
      end
    end
  end

  module Joes
    class Dog
      def identify
        :joes_dog
      end
    end
  end

  def test_dog_is_not_available_in_the_current_scope
    assert_raise(___) do
      Dog.new
    end
  end

  def test_you_can_reference_nested_classes_using_the_scope_operator
    fido = Jims::Dog.new
    rover = Joes::Dog.new
    assert_equal __, fido.identify
    assert_equal __, rover.identify

    assert_equal __, fido.class != rover.class
    assert_equal __, Jims::Dog != Joes::Dog
  end

  # ------------------------------------------------------------------

  class String
  end

  def test_bare_bones_class_names_assume_the_current_scope
    assert_equal __, AboutScope::String == String
  end

  def test_nested_string_is_not_the_same_as_the_system_string
    assert_equal __, String == "HI".class
  end

  def test_use_the_prefix_scope_operator_to_force_the_global_scope
    assert_equal __, ::String == "HI".class
  end

  # ------------------------------------------------------------------

  PI = 3.1416

  def test_constants_are_defined_with_an_initial_uppercase_letter
    assert_equal __, PI
  end

  # ------------------------------------------------------------------

  MyString = ::String

  def test_class_names_are_just_constants
    assert_equal __, MyString == ::String
    assert_equal __, MyString == "HI".class
  end

  def test_constants_can_be_looked_up_explicitly
    assert_equal __, PI == AboutScope.const_get("PI")
    assert_equal __, MyString == AboutScope.const_get("MyString")
  end

  def test_you_can_get_a_list_of_constants_for_any_class_or_module
    assert_equal __, Jims.constants
    assert Object.constants.size > _n_
  end
end
