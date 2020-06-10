require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutPatternMatching < Neo::Koan

  def test_pattern_may_not_match
    begin
      case [true, false]
      in [a, b] if a == b # The condition after pattern is called guard.
        :match
      end
    rescue Exception => ex
      # What exception has been caught?
      assert_equal __, ex.class
    end
  end

  def test_we_can_use_else
    result = case [true, false]
    in [a, b] if a == b
      :match
    else
     :no_match
    end

    assert_equal __, result
  end

  # ------------------------------------------------------------------

  def value_pattern(variable)
    case variable
    in 0
      :match_exact_value
    in 1..10
      :match_in_range
    in Integer
      :match_with_class
    else
      :no_match
    end
  end

  def test_value_pattern
    assert_equal __, value_pattern(0)
    assert_equal __, value_pattern(5)
    assert_equal __, value_pattern(100)
    assert_equal __, value_pattern('Not a Number!')
  end

  # ------------------------------------------------------------------
  # This pattern will bind variable to the value

  def variable_pattern_with_binding(variable)
    case 0
    in variable
      variable
    else
      :no_match
    end
  end

  def test_variable_pattern_with_binding
    assert_equal __, variable_pattern_with_binding(1)
  end

  # ------------------------------------------------------------------

  # We can pin the value of the variable with ^

  def variable_pattern_with_pin(variable)
    case 0
    in ^variable
      variable
    else
      :no_match
    end
  end

  def test_variable_pattern_with_pin
    assert_equal __, variable_pattern_with_pin(1)
  end

  # ------------------------------------------------------------------

  # We can drop values from pattern

  def pattern_with_dropping(variable)
    case variable
    in [_, 2]
      :match
    else
      :no_match
    end
  end

  def test_pattern_with_dropping
    assert_equal __, pattern_with_dropping(['I will not be checked', 2])
    assert_equal __, pattern_with_dropping(['I will not be checked', 'But I will!'])
  end

  # ------------------------------------------------------------------

  # We can use logical *or* in patterns

  def alternative_pattern(variable)
    case variable
    in 0 | false | nil
      :match
    else
      :no_match
    end
  end

  def test_alternative_pattern
    assert_equal __, alternative_pattern(0)
    assert_equal __, alternative_pattern(false)
    assert_equal __, alternative_pattern(nil)
    assert_equal __, alternative_pattern(4)
  end

  # ------------------------------------------------------------------

  # As pattern binds the variable to the value if pattern matches
  # pat: pat => var

  def as_pattern
    a = 'First I was afraid'

    case 'I was petrified'
    in String => a
      a
    else
      :no_match
    end
  end

  def test_as_pattern
    assert_equal __, as_pattern
  end

  # ------------------------------------------------------------------

  # Array pattern works with all objects that have #deconstruct method that returns Array
  # It is useful to cut needed parts from Array-ish objects

  class Deconstructible
    def initialize(str)
      @data = str
    end

    def deconstruct
      @data&.split('')
    end
  end

  def array_pattern(deconstructible)
    case deconstructible
    in 'a', *res, 'd'
      res
    else
      :no_match
    end
  end

  def test_array_pattern
    assert_equal __, array_pattern(Deconstructible.new('abcd'))
    assert_equal __, array_pattern(Deconstructible.new('123'))
  end

  # ------------------------------------------------------------------

  # Hash patternis quite the same as Array pattern, but it expects #deconsturct_keys(keys) method
  # It works with symbol keys for now

  class LetterAccountant
    def initialize(str)
      @data = str
    end

    def deconstruct_keys(keys)
      # we will count number of occurrences of each key in our data
      keys.map { |key| [key, @data.count(key.to_s)] }.to_h
    end
  end

  def hash_pattern(deconstructible_as_hash)
    case deconstructible_as_hash
    in {a: a, b: b}
      [a, b]
    else
      :no_match
    end
  end

  def test_hash_pattern
    assert_equal __, hash_pattern(LetterAccountant.new('aaabbc'))
    assert_equal __, hash_pattern(LetterAccountant.new('xyz'))
  end

  # we can write it even shorter
  def hash_pattern_with_sugar(deconstructible_as_hash)
    case deconstructible_as_hash
    in a:, b:
      [a, b]
    else
      :no_match
    end
  end

  def test_hash_pattern_with_sugar
    assert_equal __, hash_pattern_with_sugar(LetterAccountant.new('aaabbc'))
    assert_equal __, hash_pattern_with_sugar(LetterAccountant.new('xyz'))
  end

end