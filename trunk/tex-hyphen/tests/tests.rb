#!/usr/bin/env ruby
# $Id$
#++

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib") if __FILE__ == $0

require 'test/unit'

class TestTeX__Hyphen < Test::Unit::TestCase
  WORDS   = %w(additional declination going leaving maximizes multiple peter
               playback presents programmable representation)
  POINTS  = [
    [2, 4, 8],     # additional
    [],            # declination
    [2],           # going
    [4],           # leaving
    [3, 4],        # maximize
    [3, 5],        # multiple
    [2],           # peter
    [4],           # playback
    [],            # presents
    [3],           # programmable
    [3, 5, 8, 10]  # representation
  ]

  VISUAL  = ['ad-di-tion-al', 'declination', 'go-ing', 'leav-ing',
  'max-i-mizes', 'mul-ti-ple', 'pe-ter', 'play-back', 'presents',
  'pro-grammable', 'rep-re-sen-ta-tion']

  HY_TO   = [["addi-", "tional"], [nil, "declination"], ["go-", "ing"],
  ["leav-", "ing"], ["maxi-", "mizes"], ["mul-", "tiple"],
  ["pe-", "ter"], ["play-", "back"], [nil, "presents"],
  ["pro-", "grammable"], ["rep-", "resentation"]]

  def test_hyphenate
    @r = []
    a = TeX::Hyphen.new(:leftmin => 0, :rightmin => 0)
    assert_nothing_raised { WORDS.each { |w| @r << a.hyphenate(w) } }
    assert_equal(POINTS, @r)
    WORDS.each { |w| assert_not_nil(a.instance_eval { @cache[w] }) }
  end

  def test_visualise
    @r = []
    a = TeX::Hyphen.new { @min_left = 0; @min_right = 0 }
    assert_nothing_raised { WORDS.each { |w| @r << a.visualise(w) } }
    assert_equal(VISUAL, @r)
    WORDS.each { |w| assert_not_nil(a.instance_eval { @vcache[w] }) }
  end

  def test_hyphenate_to
    @r = []
    a = TeX::Hyphen.new(:min_left => 0, :min_right => 0)
    assert_nothing_raised { WORDS.each { |w| @r << a.hyphenate_to(w, 5) } }
    assert_equal(HY_TO, @r)
    WORDS.each { |w| assert_not_nil(a.instance_eval { @cache[w] }) }
  end
end
