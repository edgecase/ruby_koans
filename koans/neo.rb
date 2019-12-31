#!/usr/bin/env ruby
# -*- ruby -*-

begin
  require 'win32console'
rescue LoadError
end

# --------------------------------------------------------------------
# Support code for the Ruby Koans.
# --------------------------------------------------------------------

class FillMeInError < StandardError
end

def ruby_version?(version)
  RUBY_VERSION =~ /^#{version}/ ||
    (version == 'jruby' && defined?(JRUBY_VERSION)) ||
    (version == 'mri' && ! defined?(JRUBY_VERSION))
end

def in_ruby_version(*versions)
  yield if versions.any? { |v| ruby_version?(v) }
end

in_ruby_version("1.8") do
  class KeyError < StandardError
  end
end

# Standard, generic replacement value.
# If value19 is given, it is used in place of value for Ruby 1.9.
def __(value="FILL ME IN", value19=:mu)
  if RUBY_VERSION < "1.9"
    value
  else
    (value19 == :mu) ? value : value19
  end
end

# Numeric replacement value.
def _n_(value=999999, value19=:mu)
  if RUBY_VERSION < "1.9"
    value
  else
    (value19 == :mu) ? value : value19
  end
end

# Error object replacement value.
def ___(value=FillMeInError, value19=:mu)
  if RUBY_VERSION < "1.9"
    value
  else
    (value19 == :mu) ? value : value19
  end
end

# Method name replacement.
class Object
  def ____(method=nil)
    if method
      self.send(method)
    end
  end

  in_ruby_version("1.9", "2") do
    public :method_missing
  end
end

class String
  def side_padding(width)
    extra = width - self.size
    if width < 0
      self
    else
      left_padding = extra / 2
      right_padding = (extra+1)/2
      (" " * left_padding) + self + (" " *right_padding)
    end
  end
end

module Neo
  class << self
    def simple_output
      ENV['SIMPLE_KOAN_OUTPUT'] == 'true'
    end
  end

  module Color
    #shamelessly stolen (and modified) from redgreen
    COLORS = {
      :clear   => 0,  :black   => 30, :red   => 31,
      :green   => 32, :yellow  => 33, :blue  => 34,
      :magenta => 35, :cyan    => 36,
    }

    module_function

    COLORS.each do |color, value|
      module_eval "def #{color}(string); colorize(string, #{value}); end"
      module_function color
    end

    def colorize(string, color_value)
      if use_colors?
        color(color_value) + string + color(COLORS[:clear])
      else
        string
      end
    end

    def color(color_value)
      "\e[#{color_value}m"
    end

    def use_colors?
      return false if ENV['NO_COLOR']
      if ENV['ANSI_COLOR'].nil?
        if using_windows?
          using_win32console
        else
          return true
        end
      else
        ENV['ANSI_COLOR'] =~ /^(t|y)/i
      end
    end

    def using_windows?
      File::ALT_SEPARATOR
    end

    def using_win32console
      defined? Win32::Console
    end
  end

  module Assertions
    FailedAssertionError = Class.new(StandardError)

    def flunk(msg)
      raise FailedAssertionError, msg
    end

    def assert(condition, msg=nil)
      msg ||= "Failed assertion."
      flunk(msg) unless condition
      true
    end

    def assert_equal(expected, actual, msg=nil)
      msg ||= "Expected #{expected.inspect} to equal #{actual.inspect}"
      assert(expected == actual, msg)
    end

    def assert_not_equal(expected, actual, msg=nil)
      msg ||= "Expected #{expected.inspect} to not equal #{actual.inspect}"
      assert(expected != actual, msg)
    end

    def assert_nil(actual, msg=nil)
      msg ||= "Expected #{actual.inspect} to be nil"
      assert(nil == actual, msg)
    end

    def assert_not_nil(actual, msg=nil)
      msg ||= "Expected #{actual.inspect} to not be nil"
      assert(nil != actual, msg)
    end

    def assert_match(pattern, actual, msg=nil)
      msg ||= "Expected #{actual.inspect} to match #{pattern.inspect}"
      assert pattern =~ actual, msg
    end

    def assert_raise(exception)
      begin
        yield
      rescue Exception => ex
        expected = ex.is_a?(exception)
        assert(expected, "Exception #{exception.inspect} expected, but #{ex.inspect} was raised")
        return ex
      end
      flunk "Exception #{exception.inspect} expected, but nothing raised"
    end

    def assert_nothing_raised
      begin
        yield
      rescue Exception => ex
        flunk "Expected nothing to be raised, but exception #{exception.inspect} was raised"
      end
    end
  end

  class Sensei
    attr_reader :failure, :failed_test, :pass_count

    FailedAssertionError = Assertions::FailedAssertionError

    def initialize
      @pass_count = 0
      @failure = nil
      @failed_test = nil
      @observations = []
    end

    PROGRESS_FILE_NAME = '.path_progress'

    def add_progress(prog)
      @_contents = nil
      exists = File.exists?(PROGRESS_FILE_NAME)
      File.open(PROGRESS_FILE_NAME,'a+') do |f|
        f.print "#{',' if exists}#{prog}"
      end
    end

    def progress
      if @_contents.nil?
        if File.exists?(PROGRESS_FILE_NAME)
          File.open(PROGRESS_FILE_NAME,'r') do |f|
            @_contents = f.read.to_s.gsub(/\s/,'').split(',')
          end
        else
          @_contents = []
        end
      end
      @_contents
    end

    def observe(step)
      if step.passed?
        @pass_count += 1
        if @pass_count > progress.last.to_i
          @observations << Color.green("#{step.koan_file}##{step.name} has expanded your awareness.")
        end
      else
        @failed_test = step
        @failure = step.failure
        add_progress(@pass_count)
        @observations << Color.red("#{step.koan_file}##{step.name} has damaged your karma.")
        throw :neo_exit
      end
    end

    def failed?
      ! @failure.nil?
    end

    def assert_failed?
      failure.is_a?(FailedAssertionError)
    end

    def instruct
      if failed?
        @observations.each{|c| puts c }
        encourage
        guide_through_error
        a_zenlike_statement
        show_progress
      else
        end_screen
      end
    end

    def show_progress
      bar_width = 50
      total_tests = Neo::Koan.total_tests
      scale = bar_width.to_f/total_tests
      print Color.green("your path thus far [")
      happy_steps = (pass_count*scale).to_i
      happy_steps = 1 if happy_steps == 0 && pass_count > 0
      print Color.green('.'*happy_steps)
      if failed?
        print Color.red('X')
        print Color.cyan('_'*(bar_width-1-happy_steps))
      end
      print Color.green(']')
      print " #{pass_count}/#{total_tests}"
      puts
    end

    def end_screen
      if Neo.simple_output
        boring_end_screen
      else
        artistic_end_screen
      end
    end

    def boring_end_screen
      puts "Mountains are again merely mountains"
    end

    def artistic_end_screen
      "JRuby 1.9.x Koans"
      ruby_version = "(in #{'J' if defined?(JRUBY_VERSION)}Ruby #{defined?(JRUBY_VERSION) ? JRUBY_VERSION : RUBY_VERSION})"
      ruby_version = ruby_version.side_padding(54)
        completed = <<-ENDTEXT
                                  ,,   ,  ,,
                                :      ::::,    :::,
                   ,        ,,: :::::::::::::,,  ::::   :  ,
                 ,       ,,,   ,:::::::::::::::::::,  ,:  ,: ,,
            :,        ::,  , , :, ,::::::::::::::::::, :::  ,::::
           :   :    ::,                          ,:::::::: ::, ,::::
          ,     ,:::::                                  :,:::::::,::::,
      ,:     , ,:,,:                                       :::::::::::::
     ::,:   ,,:::,                                           ,::::::::::::,
    ,:::, :,,:::                                               ::::::::::::,
   ,::: :::::::,       Mountains are again merely mountains     ,::::::::::::
   :::,,,::::::                                                   ::::::::::::
 ,:::::::::::,                                                    ::::::::::::,
 :::::::::::,                                                     ,::::::::::::
:::::::::::::                                                     ,::::::::::::
::::::::::::                      Ruby Koans                       ::::::::::::
::::::::::::#{                  ruby_version                     },::::::::::::
:::::::::::,                                                      , :::::::::::
,:::::::::::::,                brought to you by                 ,,::::::::::::
::::::::::::::                                                    ,::::::::::::
 ::::::::::::::,                                                 ,:::::::::::::
 ::::::::::::,               Neo Software Artisans              , ::::::::::::
  :,::::::::: ::::                                               :::::::::::::
   ,:::::::::::  ,:                                          ,,:::::::::::::,
     ::::::::::::                                           ,::::::::::::::,
      :::::::::::::::::,                                  ::::::::::::::::
       :::::::::::::::::::,                             ::::::::::::::::
        ::::::::::::::::::::::,                     ,::::,:, , ::::,:::
          :::::::::::::::::::::::,               ::,: ::,::, ,,: ::::
              ,::::::::::::::::::::              ::,,  , ,,  ,::::
                 ,::::::::::::::::              ::,, ,   ,:::,
                      ,::::                         , ,,
                                                  ,,,
ENDTEXT
        puts completed
    end

    def encourage
      puts
      puts "The Master says:"
      puts Color.cyan("  You have not yet reached enlightenment.")
      if ((recents = progress.last(5)) && recents.size == 5 && recents.uniq.size == 1)
        puts Color.cyan("  I sense frustration. Do not be afraid to ask for help.")
      elsif progress.last(2).size == 2 && progress.last(2).uniq.size == 1
        puts Color.cyan("  Do not lose hope.")
      elsif progress.last.to_i > 0
        puts Color.cyan("  You are progressing. Excellent. #{progress.last} completed.")
      end
    end

    def guide_through_error
      puts
      puts "The answers you seek..."
      puts Color.red(indent(failure.message).join)
      puts
      puts "Please meditate on the following code:"
      puts embolden_first_line_only(indent(find_interesting_lines(failure.backtrace)))
      puts
    end

    def embolden_first_line_only(text)
      first_line = true
      text.collect { |t|
        if first_line
          first_line = false
          Color.red(t)
        else
          Color.cyan(t)
        end
      }
    end

    def indent(text)
      text = text.split(/\n/) if text.is_a?(String)
      text.collect{|t| "  #{t}"}
    end

    def find_interesting_lines(backtrace)
      backtrace.reject { |line|
        line =~ /neo\.rb/
      }
    end

    # Hat's tip to Ara T. Howard for the zen statements from his
    # metakoans Ruby Quiz (http://rubyquiz.com/quiz67.html)
    def a_zenlike_statement
      if !failed?
        zen_statement =  "Mountains are again merely mountains"
      else
        zen_statement = case (@pass_count % 10)
        when 0
          "mountains are merely mountains"
        when 1, 2
          "learn the rules so you know how to break them properly"
        when 3, 4
          "remember that silence is sometimes the best answer"
        when 5, 6
          "sleep is the best meditation"
        when 7, 8
          "when you lose, don't lose the lesson"
        else
          "things are not what they appear to be: nor are they otherwise"
        end
      end
      puts Color.green(zen_statement)
    end
  end

  class Koan
    include Assertions

    attr_reader :name, :failure, :koan_count, :step_count, :koan_file

    def initialize(name, koan_file=nil, koan_count=0, step_count=0)
      @name = name
      @failure = nil
      @koan_count = koan_count
      @step_count = step_count
      @koan_file = koan_file
    end

    def passed?
      @failure.nil?
    end

    def failed(failure)
      @failure = failure
    end

    def setup
    end

    def teardown
    end

    def meditate
      setup
      begin
        send(name)
      rescue StandardError, Neo::Sensei::FailedAssertionError => ex
        failed(ex)
      ensure
        begin
          teardown
        rescue StandardError, Neo::Sensei::FailedAssertionError => ex
          failed(ex) if passed?
        end
      end
      self
    end

    # Class methods for the Neo test suite.
    class << self
      def inherited(subclass)
        subclasses << subclass
      end

      def method_added(name)
        testmethods << name if !tests_disabled? && Koan.test_pattern =~ name.to_s
      end

      def end_of_enlightenment
        @tests_disabled = true
      end

      def command_line(args)
        args.each do |arg|
          case arg
          when /^-n\/(.*)\/$/
            @test_pattern = Regexp.new($1)
          when /^-n(.*)$/
            @test_pattern = Regexp.new(Regexp.quote($1))
          else
            if File.exist?(arg)
              load(arg)
            else
              fail "Unknown command line argument '#{arg}'"
            end
          end
        end
      end

      # Lazy initialize list of subclasses
      def subclasses
        @subclasses ||= []
      end

       # Lazy initialize list of test methods.
      def testmethods
        @test_methods ||= []
      end

      def tests_disabled?
        @tests_disabled ||= false
      end

      def test_pattern
        @test_pattern ||= /^test_/
      end

      def total_tests
        self.subclasses.inject(0){|total, k| total + k.testmethods.size }
      end
    end
  end

  class ThePath
    def walk
      sensei = Neo::Sensei.new
      each_step do |step|
        sensei.observe(step.meditate)
      end
      sensei.instruct
    end

    def each_step
      catch(:neo_exit) {
        step_count = 0
        Neo::Koan.subclasses.each_with_index do |koan,koan_index|
          koan.testmethods.each do |method_name|
            step = koan.new(method_name, koan.to_s, koan_index+1, step_count+=1)
            yield step
          end
        end
      }
    end
  end
end

END {
  Neo::Koan.command_line(ARGV)
  Neo::ThePath.new.walk
}
