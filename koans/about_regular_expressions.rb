# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutRegularExpressions < Neo::Koan
  def test_a_pattern_is_a_regular_expression
    assert_equal __, /pattern/.class
  end

  def test_a_regexp_can_search_a_string_for_matching_content
    assert_equal __, "some matching content"[/match/]
  end

  def test_a_failed_match_returns_nil
    assert_equal __, "some matching content"[/missing/]
  end

  # ------------------------------------------------------------------

  def test_question_mark_means_optional
    assert_equal __, "abbcccddddeeeee"[/ab?/]
    assert_equal __, "abbcccddddeeeee"[/az?/]
  end

  def test_plus_means_one_or_more
    assert_equal __, "abbcccddddeeeee"[/bc+/]
  end

  def test_asterisk_means_zero_or_more
    assert_equal __, "abbcccddddeeeee"[/ab*/]
    assert_equal __, "abbcccddddeeeee"[/az*/]
    assert_equal __, "abbcccddddeeeee"[/z*/]

    # THINK ABOUT IT:
    #
    # When would * fail to match?
  end

  # THINK ABOUT IT:
  #
  # We say that the repetition operators above are "greedy."
  #
  # Why?

  # ------------------------------------------------------------------

  def test_the_left_most_match_wins
    assert_equal __, "abbccc az"[/az*/]
  end

  # ------------------------------------------------------------------

  def test_character_classes_give_options_for_a_character
    animals = ["cat", "bat", "rat", "zat"]
    assert_equal __, animals.select { |a| a[/[cbr]at/] }
  end

  def test_slash_d_is_a_shortcut_for_a_digit_character_class
    assert_equal __, "the number is 42"[/[0123456789]+/]
    assert_equal __, "the number is 42"[/\d+/]
  end

  def test_character_classes_can_include_ranges
    assert_equal __, "the number is 42"[/[0-9]+/]
  end

  def test_slash_s_is_a_shortcut_for_a_whitespace_character_class
    assert_equal __, "space: \t\n"[/\s+/]
  end

  def test_slash_w_is_a_shortcut_for_a_word_character_class
    # NOTE:  This is more like how a programmer might define a word.
    assert_equal __, "variable_1 = 42"[/[a-zA-Z0-9_]+/]
    assert_equal __, "variable_1 = 42"[/\w+/]
  end

  def test_period_is_a_shortcut_for_any_non_newline_character
    assert_equal __, "abc\n123"[/a.+/]
  end

  def test_a_character_class_can_be_negated
    assert_equal __, "the number is 42"[/[^0-9]+/]
  end

  def test_shortcut_character_classes_are_negated_with_capitals
    assert_equal __, "the number is 42"[/\D+/]
    assert_equal __, "space: \t\n"[/\S+/]
    # ... a programmer would most likely do
    assert_equal __, "variable_1 = 42"[/[^a-zA-Z0-9_]+/]
    assert_equal __, "variable_1 = 42"[/\W+/]
  end

  # ------------------------------------------------------------------

  def test_slash_a_anchors_to_the_start_of_the_string
    assert_equal __, "start end"[/\Astart/]
    assert_equal __, "start end"[/\Aend/]
  end

  def test_slash_z_anchors_to_the_end_of_the_string
    assert_equal __, "start end"[/end\z/]
    assert_equal __, "start end"[/start\z/]
  end

  def test_caret_anchors_to_the_start_of_lines
    assert_equal __, "num 42\n2 lines"[/^\d+/]
  end

  def test_dollar_sign_anchors_to_the_end_of_lines
    assert_equal __, "2 lines\nnum 42"[/\d+$/]
  end

  def test_slash_b_anchors_to_a_word_boundary
    assert_equal __, "bovine vines"[/\bvine./]
  end

  # ------------------------------------------------------------------

  def test_parentheses_group_contents
    assert_equal __, "ahahaha"[/(ha)+/]
  end

  # ------------------------------------------------------------------

  def test_parentheses_also_capture_matched_content_by_number
    assert_equal __, "Gray, James"[/(\w+), (\w+)/, 1]
    assert_equal __, "Gray, James"[/(\w+), (\w+)/, 2]
  end

  def test_variables_can_also_be_used_to_access_captures
    assert_equal __, "Name:  Gray, James"[/(\w+), (\w+)/]
    assert_equal __, $1
    assert_equal __, $2
  end

  # ------------------------------------------------------------------

  def test_a_vertical_pipe_means_or
    grays = /(James|Dana|Summer) Gray/
    assert_equal __, "James Gray"[grays]
    assert_equal __, "Summer Gray"[grays, 1]
    assert_equal __, "Jim Gray"[grays, 1]
  end

  # THINK ABOUT IT:
  #
  # Explain the difference between a character class ([...]) and alternation (|).

  # ------------------------------------------------------------------

  def test_scan_is_like_find_all
    assert_equal __, "one two-three".scan(/\w+/)
  end

  def test_sub_is_like_find_and_replace
    assert_equal __, "one two-three".sub(/(t\w*)/) { $1[0, 1] }
  end

  def test_gsub_is_like_find_and_replace_all
    assert_equal __, "one two-three".gsub(/(t\w*)/) { $1[0, 1] }
  end
end
