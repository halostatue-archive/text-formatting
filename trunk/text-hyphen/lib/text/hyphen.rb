# :title: Text::Hyphen
# :main: Text::Hyphen

module Text; end

    # = Introduction
    # Text::Hyphen -- hyphenate words using modified versions of TeX
    # hyphenation patterns.
    #
    # == Usage
    #   require 'text/hyphen'
    #   hh = Text::Hyphen.new(:language => 'en_us', :left => 2, :right => 2)
    #     # Defaults to the above
    #   hh = TeX::Hyphen.new
    #
    #   word = "representation"
    #   points = hyp.hyphenate(word)  #=> [3, 5, 8, 10]
    #   puts hyp.visualize(word)      #=> rep-re-sen-ta-tion
    #
    # == Description
    # Creates a new Hyphen object and loads the language patterns into
    # memory. The hyphenator can then be asked for the hyphenation of
    # a word. If no language is specified, then the language en_us (EN_US)
    # is used by default.
    #
    # Copyright::   Copyright (c) 2004 - 2005 Austin Ziegler
    # Version::     1.0.0
    # Based On::    <tt>TeX::Hyphen</tt> 0.4 (c) 2003 - 2004 Martin DeMello
    #               and Austin Ziegler, in turn based on Perl's
    #               <tt>TeX::Hyphen</tt>
    #               [http://search.cpan.org/author/JANPAZ/TeX-Hyphen-0.140/lib/TeX/Hyphen.pm]
    #               Copyright (c) 1997 - 2002 Jan Pazdziora
    # Licence::     Ruby's
class Text::Hyphen
  DEBUG   = false
  VERSION = '1.0.0'

  DEFAULT_MIN_LEFT  = 2
  DEFAULT_MIN_RIGHT = 2

    # No fewer than this number of letters will show up to the left of the
    # hyphen. This overrides the default specified in the language.
  attr_accessor :left
    # No fewer than this number of letters will show up to the right of the
    # hyphen. This overrides the default specified in the language.
  attr_accessor :right
    # The name of the language to be used in hyphenating words. This will be
    # a two or three character ISO 639 code, with the two character form
    # being the canonical resource name. This will load the language
    # hyphenation definitions from text/hyphen/language/&lt;code&gt; as
    # a Ruby class. The resource 'text/hyphen/language/en_us' defines the
    # language class Text::Hyphen::Language::EN_US. It also defines the
    # secondary forms Text::Hyphen::Language::EN and
    # Text::Hyphen::Language::ENG_US.
    #
    # Minimal transformations will be performed on the language code
    # provided, such that any dashes are converted to underscores (e.g.,
    # 'en-us' becomes 'en_us') and all characters are regularised. Resource
    # names will be downcased and class names will be upcased (e.g., 'Pt'
    # for the Portuguese language becomes 'pt' and 'PT', respectively).
    #
    # The language may be 
  attr_accessor :language
  def language=(lang) #:nodoc:
    require 'text/hyphen/language' unless defined?(Text::Hyphen::Language)
    if lang.kind_of?(Text::Hyphen::Language)
      @iso_language = lang.to_s.split(%r{::}o)[-1].downcase
      @language     = lang
    else
      @iso_language = lang.downcase
      load_language
    end
    @iso_language
  end
    # Returns the language's ISO 639 ID, e.g., "en_us" or "pt".
  attr_reader   :iso_language

    # The following initializations are equivalent:
    #
    #   hyp = TeX::Hyphenate.new(:language => "EU")
    #   hyp = TeX::Hyphenate.new { |h| h.language = "EU" }
  def initialize(options = {}) # :yields self:
    @iso_language = options[:language]
    @left         = options[:left]
    @right        = options[:right]

    @cache        = {}
    @vcache       = {}

    @hyphen       = {}
    @begin_hyphen = {}
    @end_hyphen   = {}
    @both_hyphen  = {}
    @exception    = {}

    @first_load = true
    yield self if block_given?
    @first_load = false

    load_language

    @left       ||= DEFAULT_MIN_LEFT
    @right      ||= DEFAULT_MIN_RIGHT
  end

    # Returns a list of places where the word can be divided, as
    #
    #   hyp.hyphenate('representation')
    #
    # returns [3, 5, 8, 10]. If the word has been hyphenated previously, it
    # will be returned from a per-instance cache.
  def hyphenate(word)
    word = word.downcase
    $stderr.puts "Hyphenating #{word}" if DEBUG
    return @cache[word] if @cache.has_key?(word)
    res = @language.exceptions[word]
    return @cache[word] = make_result_list(res) if res

    result = [0] * (word.split(//).size + 1)
    rightstop = word.split(//).size - @right

    updater = Proc.new do |result, hash, str, pos|
      if hash.has_key?(str)
        $stderr.print "#{pos}: #{str}: #{hash[str]}" if DEBUG
        hash[str].split(//).each_with_index do |cc, ii|
          cc = cc.to_i
          result[ii + pos] = cc if cc > result[ii + pos]
        end
        $stderr.print ": #{result}\n" if DEBUG
      end
    end

      # Walk the word
    (0..rightstop).each do |pos|
      restlength = word.length - pos
      (1..restlength).each do |length|
        substr = word[pos, length]
        updater[result, @language.hyphen, substr, pos]
        updater[result, @language.start, substr, pos] if pos.zero?
        updater[result, @language.stop, substr, pos] if (length == restlength)
      end
    end

    updater[result, @language.both, word, 0] if @language.both[word]

    (0..@left).each { |i| result[i] = 0 }
    ((-1 - @right)..(-1)).each { |i| result[i] = 0 }
    @cache[word] = make_result_list(result)
  end

    # Returns a visualization of the hyphenation points, so:
    #
    #   hyp.visualize('representation')
    #
    # should return <tt>rep-re-sen-ta-tion</tt>, at least for English
    # patterns. If the word has been visualised previously, it will be
    # returned from a per-instance cache.
  def visualise(word)
    return @vcache[word] if @vcache.has_key?(word)
    w = word.dup
    hyphenate(w).each_with_index do |pos, n| 
      w[pos.to_i + n, 0] = '-' if pos != 0
    end
    @vcache[word] = w
  end

  alias visualize visualise

  def clear_cache!
    @cache.clear
    @vcache.clear
  end

    # This function will hyphenate a word so that the first point is at most
    # +size+ characters.
  def hyphenate_to(word, size)
    point = hyphenate(word).delete_if { |e| e >= size }.max
    if point.nil?
      [nil, word]
    else
      [word[0 ... point] + "-", word[point .. -1]]
    end
  end

  def stats
    _b = @ruleset_mod.rules[:both].size
    _s = @ruleset_mod.rules[:begin].size
    _e = @ruleset_mod.rules[:end].size
    _h = @ruleset_mod.rules[:hyphen].size
    _x = @ruleset_mod.rules[:exception].size

    s = <<-EOS
Statistics for #{@@language.inspect}:
  all         : #{_b + _s + _e + _h + _x}
  exceptions  : #{_x}
  begin       : #{_s}
  end         : #{_e}
  both        : #{_b}
    EOS
  end

private
  def updateresult(hash, str, pos) #:nodoc:
    if hash.has_key?(str)
      STDERR.print "#{pos}: #{str}: #{hash[str]}" if DEBUG
      hash[str].split('').each_with_index do |c, i| 
        c = c.to_i
        @result[i + pos] = c if c > @result[i + pos]
      end
      STDERR.puts ": #{@result}" if DEBUG
    end
  end

  def make_result_list(res) #:nodoc:
    r = []
    res.each_with_index { |c, i| r <<  i * (c.to_i % 2) }
    r.reject { |i| i.to_i == 0 }
  end

  def load_language
    return if @first_load

    @iso_language ||= "en_us"

    require "text/hyphen/language/#{@iso_language}"

    @language   = Text::Hyphen::Language.const_get(@iso_language.upcase)
    @left     ||= @language.left
    @right    ||= @language.right

    @iso_language
  end
end
