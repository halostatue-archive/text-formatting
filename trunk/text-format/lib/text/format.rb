# :title: Text::Format
# :main: Text::Format
#--
# Text::Format for Ruby
# Version 0.63.1
#
# Copyright (c) 2002 - 2003 Austin Ziegler
#
# $Id$
#
# ==========================================================================
# Revision History ::
# YYYY.MM.DD  Change ID   Developer
#             Description
# --------------------------------------------------------------------------
# 2002.10.18              Austin Ziegler
#             Fixed a minor problem with tabs not being counted. Changed
#             abbreviations from Hash to Array to better suit Ruby's
#             capabilities. Fixed problems with the way that Array arguments
#             are handled in calls to the major object types, excepting in
#             Text::Format#expand and Text::Format#unexpand (these will
#             probably need to be fixed).
# 2002.10.30              Austin Ziegler
#             Fixed the ordering of the <=> for binary tests. Fixed
#             Text::Format#expand and Text::Format#unexpand to handle array
#             arguments better.
# 2003.01.24              Austin Ziegler
#             Fixed a problem with Text::Format::RIGHT_FILL handling where a
#             single word is larger than #columns. Removed Comparable
#             capabilities (<=> doesn't make sense; == does). Added Symbol
#             equivalents for the Hash initialization. Hash initialization has
#             been modified so that values are set as follows (Symbols are
#             highest priority; strings are middle; defaults are lowest):
#                 @columns = arg[:columns] || arg['columns'] || @columns
#             Added #hard_margins, #split_rules, #hyphenator, and #split_words.
# 2003.02.07              Austin Ziegler
#             Fixed the installer for proper case-sensitive handling.
# 2003.03.28              Austin Ziegler
#             Added the ability for a hyphenator to receive the formatter
#             object. Fixed a bug for strings matching /\A\s*\Z/ failing
#             entirely. Fixed a test case failing under 1.6.8. 
# 2003.04.04              Austin Ziegler
#             Handle the case of hyphenators returning nil for first/rest.
# 2003.09.17          Austin Ziegler
#             Fixed a problem where #paragraphs(" ") was raising
#             NoMethodError.
#
# ==========================================================================
#++
module Text #:nodoc:
    # = Introduction
    #
    # Text::Format provides the ability to nicely format fixed-width text with
    # knowledge of the writeable space (number of columns), margins, and
    # indentation settings.
    #
    # Copyright::   Copyright (c) 2002 - 2003 by Austin Ziegler
    # Version::     0.63
    # Based On::    Perl
    #               Text::Format[http://search.cpan.org/author/GABOR/Text-Format0.52/lib/Text/Format.pm],
    #               Copyright (c) 1998 Gábor Egressy
    # Licence::     Ruby's, Perl Artistic, or GPL version 2 (or later)
    #
  class Format
    VERSION = '0.63.1'

      # Local abbreviations. More can be added with Text::Format.abbreviations
    ABBREV = [ 'Mr', 'Mrs', 'Ms', 'Jr', 'Sr' ]

      # Formatting values
    LEFT_ALIGN  = 0
    RIGHT_ALIGN = 1
    RIGHT_FILL  = 2
    JUSTIFY     = 3

      # Word split modes (only applies when #hard_margins is true).
    SPLIT_FIXED                     = 1
    SPLIT_CONTINUATION              = 2
    SPLIT_HYPHENATION               = 4
    SPLIT_CONTINUATION_FIXED        = SPLIT_CONTINUATION | SPLIT_FIXED
    SPLIT_HYPHENATION_FIXED         = SPLIT_HYPHENATION | SPLIT_FIXED
    SPLIT_HYPHENATION_CONTINUATION  = SPLIT_HYPHENATION | SPLIT_CONTINUATION
    SPLIT_ALL                       = SPLIT_HYPHENATION | SPLIT_CONTINUATION | SPLIT_FIXED

      # Words forcibly split by Text::Format will be stored as split words.
      # This class represents a word forcibly split.
    class SplitWord
        # The word that was split.
      attr_reader :word
        # The first part of the word that was split.
      attr_reader :first
        # The remainder of the word that was split.
      attr_reader :rest

      def initialize(word, first, rest) #:nodoc:
        @word = word
        @first = first
        @rest = rest
      end
    end

  private
    LEQ_RE = /[.?!]['"]?$/

    def brk_re(i) #:nodoc:
      %r/((?:\S+\s+){#{i}})(.+)/
    end

    def posint(p) #:nodoc:
      p.to_i.abs
    end

  public
      # Compares two Text::Format objects. All settings of the objects are
      # compared *except* #hyphenator. Generated results (e.g., #split_words)
      # are not compared, either.
    def ==(o)
      (@text          ==  o.text)           &&
      (@columns       ==  o.columns)        &&
      (@left_margin   ==  o.left_margin)    &&
      (@right_margin  ==  o.right_margin)   &&
      (@hard_margins  ==  o.hard_margins)   &&
      (@split_rules   ==  o.split_rules)    &&
      (@first_indent  ==  o.first_indent)   &&
      (@body_indent   ==  o.body_indent)    &&
      (@tag_text      ==  o.tag_text)       &&
      (@tabstop       ==  o.tabstop)        &&
      (@format_style  ==  o.format_style)   &&
      (@extra_space   ==  o.extra_space)    &&
      (@tag_paragraph ==  o.tag_paragraph)  &&
      (@nobreak       ==  o.nobreak)        &&
      (@abbreviations ==  o.abbreviations)  &&
      (@nobreak_regex ==  o.nobreak_regex)
    end

      # The text to be manipulated. Note that value is optional, but if the
      # formatting functions are called without values, this text is what will
      # be formatted.
      #
      # *Default*::       <tt>[]</tt>
      # <b>Used in</b>::  All methods
    attr_accessor :text

      # The total width of the format area. The margins, indentation, and text
      # are formatted into this space.
      #
      #                             COLUMNS
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   left margin  indent  text is formatted into here  right margin
      #
      # *Default*::       <tt>72</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>,
      #                   <tt>#center</tt>
    attr_reader :columns

      # The total width of the format area. The margins, indentation, and text
      # are formatted into this space. The value provided is silently
      # converted to a positive integer.
      #
      #                             COLUMNS
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   left margin  indent  text is formatted into here  right margin
      #
      # *Default*::       <tt>72</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>,
      #                   <tt>#center</tt>
    def columns=(c)
      @columns = posint(c)
    end

      # The number of spaces used for the left margin.
      #
      #                             columns
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   LEFT MARGIN  indent  text is formatted into here  right margin
      #
      # *Default*::       <tt>0</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>,
      #                   <tt>#center</tt>
    attr_reader :left_margin

      # The number of spaces used for the left margin. The value provided is
      # silently converted to a positive integer value.
      #
      #                             columns
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   LEFT MARGIN  indent  text is formatted into here  right margin
      #
      # *Default*::       <tt>0</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>,
      #                   <tt>#center</tt>
    def left_margin=(left)
      @left_margin = posint(left)
    end

      # The number of spaces used for the right margin.
      #
      #                             columns
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   left margin  indent  text is formatted into here  RIGHT MARGIN
      #
      # *Default*::       <tt>0</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>,
      #                   <tt>#center</tt>
    attr_reader :right_margin

      # The number of spaces used for the right margin. The value provided is
      # silently converted to a positive integer value.
      #
      #                             columns
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   left margin  indent  text is formatted into here  RIGHT MARGIN
      #
      # *Default*::       <tt>0</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>,
      #                   <tt>#center</tt>
    def right_margin=(r)
      @right_margin = posint(r)
    end

      # The number of spaces to indent the first line of a paragraph.
      #
      #                             columns
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   left margin  INDENT  text is formatted into here  right margin
      #
      # *Default*::       <tt>4</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_reader :first_indent

      # The number of spaces to indent the first line of a paragraph. The
      # value provided is silently converted to a positive integer value.
      #
      #                             columns
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   left margin  INDENT  text is formatted into here  right margin
      #
      # *Default*::       <tt>4</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def first_indent=(f)
      @first_indent = posint(f)
    end

      # The number of spaces to indent all lines after the first line of a
      # paragraph.
      #
      #                             columns
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   left margin  INDENT  text is formatted into here  right margin
      #
      # *Default*::       <tt>0</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
  attr_reader :body_indent

      # The number of spaces to indent all lines after the first line of
      # a paragraph. The value provided is silently converted to a
      # positive integer value.
      #
      #                             columns
      #  <-------------------------------------------------------------->
      #  <-----------><------><---------------------------><------------>
      #   left margin  INDENT  text is formatted into here  right margin
      #
      # *Default*::       <tt>0</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def body_indent=(b)
      @body_indent = posint(b)
    end

      # Normally, words larger than the format area will be placed on a line
      # by themselves. Setting this to +true+ will force words larger than the
      # format area to be split into one or more "words" each at most the size
      # of the format area. The first line and the original word will be
      # placed into <tt>#split_words</tt>. Note that this will cause the
      # output to look *similar* to a #format_style of JUSTIFY. (Lines will be
      # filled as much as possible.)
      #
      # *Default*::       +false+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_accessor :hard_margins

      # An array of words split during formatting if #hard_margins is set to
      # +true+.
      #   #split_words << Text::Format::SplitWord.new(word, first, rest)
    attr_reader :split_words

      # The object responsible for hyphenating. It must respond to
      # #hyphenate_to(word, size) or #hyphenate_to(word, size, formatter) and
      # return an array of the word split into two parts; if there is a
      # hyphenation mark to be applied, responsibility belongs to the
      # hyphenator object. The size is the MAXIMUM size permitted, including
      # any hyphenation marks. If the #hyphenate_to method has an arity of 3,
      # the formatter will be provided to the method. This allows the
      # hyphenator to make decisions about the hyphenation based on the
      # formatting rules.
      #
      # *Default*::       +nil+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_reader :hyphenator

      # The object responsible for hyphenating. It must respond to
      # #hyphenate_to(word, size) and return an array of the word hyphenated
      # into two parts. The size is the MAXIMUM size permitted, including any
      # hyphenation marks.
      #
      # *Default*::       +nil+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def hyphenator=(h)
      raise ArgumentError, "#{h.inspect} is not a valid hyphenator." unless h.respond_to?(:hyphenate_to)
      arity = h.method(:hyphenate_to).arity
      raise ArgumentError, "#{h.inspect} must have exactly two or three arguments." unless [2, 3].include?(arity)
      @hyphenator = h
      @hyphenator_arity = arity
    end

      # Specifies the split mode; used only when #hard_margins is set to
      # +true+. Allowable values are:
      # [+SPLIT_FIXED+]         The word will be split at the number of
      #                         characters needed, with no marking at all.
      #      repre
      #      senta
      #      ion
      # [+SPLIT_CONTINUATION+]  The word will be split at the number of
      #                         characters needed, with a C-style continuation
      #                         character. If a word is the only item on a
      #                         line and it cannot be split into an
      #                         appropriate size, SPLIT_FIXED will be used.
      #       repr\
      #       esen\
      #       tati\
      #       on
      # [+SPLIT_HYPHENATION+]   The word will be split according to the
      #                         hyphenator specified in #hyphenator. If there
      #                         is no #hyphenator specified, works like
      #                         SPLIT_CONTINUATION. The example is using
      #                         TeX::Hyphen. If a word is the only item on a
      #                         line and it cannot be split into an
      #                         appropriate size, SPLIT_CONTINUATION mode will
      #                         be used.
      #       rep-
      #       re-
      #       sen-
      #       ta-
      #       tion
      #
      # *Default*::       <tt>Text::Format::SPLIT_FIXED</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_reader :split_rules

      # Specifies the split mode; used only when #hard_margins is set to
      # +true+. Allowable values are:
      # [+SPLIT_FIXED+]         The word will be split at the number of
      #                         characters needed, with no marking at all.
      #      repre
      #      senta
      #      ion
      # [+SPLIT_CONTINUATION+]  The word will be split at the number of
      #                         characters needed, with a C-style continuation
      #                         character.
      #       repr\
      #       esen\
      #       tati\
      #       on
      # [+SPLIT_HYPHENATION+]   The word will be split according to the
      #                         hyphenator specified in #hyphenator. If there
      #                         is no #hyphenator specified, works like
      #                         SPLIT_CONTINUATION. The example is using
      #                         TeX::Hyphen as the #hyphenator.
      #       rep-
      #       re-
      #       sen-
      #       ta-
      #       tion
      #
      # These values can be bitwise ORed together (e.g., <tt>SPLIT_FIXED |
      # SPLIT_CONTINUATION</tt>) to provide fallback split methods. In the
      # example given, an attempt will be made to split the word using the
      # rules of SPLIT_CONTINUATION; if there is not enough room, the word
      # will be split with the rules of SPLIT_FIXED. These combinations are
      # also available as the following values:
      # * +SPLIT_CONTINUATION_FIXED+
      # * +SPLIT_HYPHENATION_FIXED+
      # * +SPLIT_HYPHENATION_CONTINUATION+
      # * +SPLIT_ALL+
      #
      # *Default*::       <tt>Text::Format::SPLIT_FIXED</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def split_rules=(s)
      raise ArgumentError, "Invalid value provided for split_rules." if ((s < SPLIT_FIXED) || (s > SPLIT_ALL))
      @split_rules = s
    end

      # Indicates whether sentence terminators should be followed by a single
      # space (+false+), or two spaces (+true+).
      #
      # *Default*::       +false+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_accessor :extra_space

      # Defines the current abbreviations as an array. This is only used if
      # extra_space is turned on.
      #
      # If one is abbreviating "President" as "Pres." (abbreviations =
      # ["Pres"]), then the results of formatting will be as illustrated in
      # the table below:
      #
      #       extra_space  |  include?        |  !include?
      #         true       |  Pres. Lincoln   |  Pres.  Lincoln
      #         false      |  Pres. Lincoln   |  Pres. Lincoln
      #
      # *Default*::       <tt>{}</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_accessor :abbreviations

      # Indicates whether the formatting of paragraphs should be done with
      # tagged paragraphs. Useful only with <tt>#tag_text</tt>.
      #
      # *Default*::       +false+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_accessor :tag_paragraph

      # The array of text to be placed before each paragraph when
      # <tt>#tag_paragraph</tt> is +true+. When <tt>#format()</tt> is called,
      # only the first element of the array is used. When <tt>#paragraphs</tt>
      # is called, then each entry in the array will be used once, with
      # corresponding paragraphs. If the tag elements are exhausted before the
      # text is exhausted, then the remaining paragraphs will not be tagged.
      # Regardless of indentation settings, a blank line will be inserted
      # between all paragraphs when <tt>#tag_paragraph</tt> is +true+.
      #
      # *Default*::       <tt>[]</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_accessor :tag_text

      # Indicates whether or not the non-breaking space feature should be
      # used.
      #
      # *Default*::       +false+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_accessor :nobreak

      # A hash which holds the regular expressions on which spaces should not
      # be broken. The hash is set up such that the key is the first word and
      # the value is the second word.
      #
      # For example, if +nobreak_regex+ contains the following hash:
      #
      #   { '^Mrs?\.$' => '\S+$', '^\S+$' => '^(?:S|J)r\.$'}
      #
      # Then "Mr. Jones", "Mrs. Jones", and "Jones Jr." would not be broken.
      # If this simple matching algorithm indicates that there should not be a
      # break at the current end of line, then a backtrack is done until there
      # are two words on which line breaking is permitted. If two such words
      # are not found, then the end of the line will be broken *regardless*.
      # If there is a single word on the current line, then no backtrack is
      # done and the word is stuck on the end.
      #
      # *Default*::       <tt>{}</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_accessor :nobreak_regex

      # Indicates the number of spaces that a single tab represents.
      #
      # *Default*::       <tt>8</tt>
      # <b>Used in</b>::  <tt>#expand</tt>, <tt>#unexpand</tt>,
      #                   <tt>#paragraphs</tt>
    attr_reader :tabstop

      # Indicates the number of spaces that a single tab represents.
      #
      # *Default*::       <tt>8</tt>
      # <b>Used in</b>::  <tt>#expand</tt>, <tt>#unexpand</tt>,
      #                   <tt>#paragraphs</tt>
    def tabstop=(t)
      @tabstop = posint(t)
    end

      # Specifies the format style. Allowable values are:
      # [+LEFT_ALIGN+]    Left justified, ragged right.
      #      |A paragraph that is|
      #      |left aligned.|
      # [+RIGHT_ALIGN+]   Right justified, ragged left.
      #      |A paragraph that is|
      #      |     right aligned.|
      # [+RIGHT_FILL+]    Left justified, right ragged, filled to width by
      #                   spaces. (Essentially the same as +LEFT_ALIGN+ except
      #                   that lines are padded on the right.)
      #      |A paragraph that is|
      #      |left aligned.      |
      # [+JUSTIFY+]       Fully justified, words filled to width by spaces,
      #                   except the last line.
      #      |A paragraph  that|
      #      |is     justified.|
      #
      # *Default*::       <tt>Text::Format::LEFT_ALIGN</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    attr_reader :format_style

      # Specifies the format style. Allowable values are:
      # [+LEFT_ALIGN+]    Left justified, ragged right.
      #      |A paragraph that is|
      #      |left aligned.|
      # [+RIGHT_ALIGN+]   Right justified, ragged left.
      #      |A paragraph that is|
      #      |     right aligned.|
      # [+RIGHT_FILL+]    Left justified, right ragged, filled to width by
      #                   spaces. (Essentially the same as +LEFT_ALIGN+ except
      #                   that lines are padded on the right.)
      #      |A paragraph that is|
      #      |left aligned.      |
      # [+JUSTIFY+]       Fully justified, words filled to width by spaces.
      #      |A paragraph  that|
      #      |is     justified.|
      #
      # *Default*::       <tt>Text::Format::LEFT_ALIGN</tt>
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def format_style=(fs)
      raise ArgumentError, "Invalid value provided for format_style." if ((fs < LEFT_ALIGN) || (fs > JUSTIFY))
      @format_style = fs
    end

      # Indicates that the format style is left alignment.
      #
      # *Default*::       +true+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def left_align?
      return @format_style == LEFT_ALIGN
    end

      # Indicates that the format style is right alignment.
      #
      # *Default*::       +false+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def right_align?
      return @format_style == RIGHT_ALIGN
    end

      # Indicates that the format style is right fill.
      #
      # *Default*::       +false+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def right_fill?
      return @format_style == RIGHT_FILL
    end

      # Indicates that the format style is full justification.
      #
      # *Default*::       +false+
      # <b>Used in</b>::  <tt>#format</tt>, <tt>#paragraphs</tt>
    def justify?
      return @format_style == JUSTIFY
    end

      # The default implementation of #hyphenate_to implements
      # SPLIT_CONTINUATION.
    def hyphenate_to(word, size)
      [word[0 .. (size - 2)] + "\\", word[(size - 1) .. -1]]
    end

  private
    def __do_split_word(word, size) #:nodoc:
      [word[0 .. (size - 1)], word[size .. -1]]
    end

    def __format(to_wrap) #:nodoc:
      words = to_wrap.split(/\s+/).compact
      words.shift if words[0].nil? or words[0].empty?
      to_wrap = []

      abbrev = false
      width = @columns - @first_indent - @left_margin - @right_margin
      indent_str = ' ' * @first_indent
      first_line = true
      line = words.shift
      abbrev = __is_abbrev(line) unless line.nil? || line.empty?

      while w = words.shift
        if (w.size + line.size < (width - 1)) ||
           ((line !~ LEQ_RE || abbrev) && (w.size + line.size < width))
          line << " " if (line =~ LEQ_RE) && (not abbrev)
          line << " #{w}"
        else
          line, w = __do_break(line, w) if @nobreak
          line, w = __do_hyphenate(line, w, width) if @hard_margins
          if w.index(/\s+/)
            w, *w2 = w.split(/\s+/)
            words.unshift(w2)
            words.flatten!
          end
          to_wrap << __make_line(line, indent_str, width, w.nil?) unless line.nil?
          if first_line
            first_line = false
            width = @columns - @body_indent - @left_margin - @right_margin
            indent_str = ' ' * @body_indent
          end
          line = w
        end

        abbrev = __is_abbrev(w) unless w.nil?
      end

      loop do
        break if line.nil? or line.empty?
        line, w = __do_hyphenate(line, w, width) if @hard_margins
        to_wrap << __make_line(line, indent_str, width, w.nil?)
        line = w
      end

      if (@tag_paragraph && (to_wrap.size > 0)) then
        clr = %r{`(\w+)'}.match([caller(1)].flatten[0])[1]
        clr = "" if clr.nil?

        if ((not @tag_text[0].nil?) && (@tag_cur.size < 1) &&
            (clr != "__paragraphs")) then
          @tag_cur = @tag_text[0]
        end

        fchar = /(\S)/.match(to_wrap[0])[1]
        white = to_wrap[0].index(fchar)
        if ((white - @left_margin - 1) > @tag_cur.size) then
          white = @tag_cur.size + @left_margin
          to_wrap[0].gsub!(/^ {#{white}}/, "#{' ' * @left_margin}#{@tag_cur}")
        else
          to_wrap.unshift("#{' ' * @left_margin}#{@tag_cur}\n")
        end
      end
      to_wrap.join('')
    end

      # format lines in text into paragraphs with each element of @wrap a
      # paragraph; uses Text::Format.format for the formatting
    def __paragraphs(to_wrap) #:nodoc:
      if ((@first_indent == @body_indent) || @tag_paragraph) then
        p_end = "\n"
      else
        p_end = ''
      end

      cnt = 0
      ret = []
      to_wrap.each do |tw|
        @tag_cur = @tag_text[cnt] if @tag_paragraph
        @tag_cur = '' if @tag_cur.nil?
        line = __format(tw)
        ret << "#{line}#{p_end}" if (not line.nil?) && (line.size > 0)
        cnt += 1
      end

      ret[-1].chomp! unless ret.empty?
      ret.join('')
    end

      # center text using spaces on left side to pad it out empty lines
      # are preserved
    def __center(to_center) #:nodoc:
      tabs = 0
      width = @columns - @left_margin - @right_margin
      centered = []
      to_center.each do |tc|
        s = tc.strip
        tabs = s.count("\t")
        tabs = 0 if tabs.nil?
        ct = ((width - s.size - (tabs * @tabstop) + tabs) / 2)
        ct = (width - @left_margin - @right_margin) - ct
        centered << "#{s.rjust(ct)}\n"
      end
      centered.join('')
    end

      # expand tabs to spaces should be similar to Text::Tabs::expand
    def __expand(to_expand) #:nodoc:
      expanded = []
      to_expand.split("\n").each { |te| expanded << te.gsub(/\t/, ' ' * @tabstop) }
      expanded.join('')
    end

    def __unexpand(to_unexpand) #:nodoc:
      unexpanded = []
      to_unexpand.split("\n").each { |tu| unexpanded << tu.gsub(/ {#{@tabstop}}/, "\t") }
      unexpanded.join('')
    end

    def __is_abbrev(word) #:nodoc:
        # remove period if there is one.
      w = word.gsub(/\.$/, '') unless word.nil?
      return true if (!@extra_space || ABBREV.include?(w) || @abbreviations.include?(w))
      false
    end

    def __make_line(line, indent, width, last = false) #:nodoc:
      lmargin = " " * @left_margin
      fill = " " * (width - line.size) if right_fill? && (line.size <= width)

      if (justify? && ((not line.nil?) && (not line.empty?)) && line =~ /\S+\s+\S+/ && !last)
        spaces = width - line.size
        words = line.split(/(\s+)/)
        ws = spaces / (words.size / 2)
        spaces = spaces % (words.size / 2) if ws > 0
        words.reverse.each do |rw|
          next if (rw =~ /^\S/)
          rw.sub!(/^/, " " * ws)
          next unless (spaces > 0)
          rw.sub!(/^/, " ")
          spaces -= 1
        end
        line = words.join('')
      end
      line = "#{lmargin}#{indent}#{line}#{fill}\n" unless line.nil?
      if right_align? && (not line.nil?)
        line.sub(/^/, " " * (@columns - @right_margin - (line.size - 1)))
      else
        line
      end
    end

    def __do_hyphenate(line, next_line, width) #:nodoc:
      rline = line.dup rescue line
      rnext = next_line.dup rescue next_line
      loop do
        if rline.size == width
          break
        elsif rline.size > width
          words = rline.strip.split(/\s+/)
          word = words[-1].dup
          size = width - rline.size + word.size
          if (size <= 0)
            words[-1] = nil
            rline = words.join(' ').strip
            rnext = "#{word} #{rnext}".strip
            next
          end

          first = rest = nil

          if ((@split_rules & SPLIT_HYPHENATION) != 0)
            if @hyphenator_arity == 2
              first, rest = @hyphenator.hyphenate_to(word, size)
            else
              first, rest = @hyphenator.hyphenate_to(word, size, self)
            end
          end

          if ((@split_rules & SPLIT_CONTINUATION) != 0) and first.nil?
            first, rest = self.hyphenate_to(word, size)
          end

          if ((@split_rules & SPLIT_FIXED) != 0) and first.nil?
            first.nil? or @split_rules == SPLIT_FIXED
            first, rest = __do_split_word(word, size)
          end

          if first.nil?
            words[-1] = nil
            rest = word
          else
            words[-1] = first
            @split_words << SplitWord.new(word, first, rest)
          end
          rline = words.join(' ').strip
          rnext = "#{rest} #{rnext}".strip
          break
        else
          break if rnext.nil? or rnext.empty? or rline.nil? or rline.empty?
          words = rnext.split(/\s+/)
          word = words.shift
          size = width - rline.size - 1

          if (size <= 0)
            rnext = "#{word} #{words.join(' ')}".strip
            break
          end

          first = rest = nil

          if ((@split_rules & SPLIT_HYPHENATION) != 0)
            if @hyphenator_arity == 2
              first, rest = @hyphenator.hyphenate_to(word, size)
            else
              first, rest = @hyphenator.hyphenate_to(word, size, self)
            end
          end

          first, rest = self.hyphenate_to(word, size) if ((@split_rules & SPLIT_CONTINUATION) != 0) and first.nil?

          first, rest = __do_split_word(word, size) if ((@split_rules & SPLIT_FIXED) != 0) and first.nil?

          if (rline.size + (first ? first.size : 0)) < width
            @split_words << SplitWord.new(word, first, rest)
            rline = "#{rline} #{first}".strip
            rnext = "#{rest} #{words.join(' ')}".strip
          end
          break
        end
      end
      [rline, rnext]
    end

    def __do_break(line, next_line) #:nodoc:
      no_brk = false
      words = []
      words = line.split(/\s+/) unless line.nil?
      last_word = words[-1]

      @nobreak_regex.each { |k, v| no_brk = ((last_word =~ /#{k}/) and (next_line =~ /#{v}/)) }

      if no_brk && words.size > 1
        i = words.size
        while i > 0
          no_brk = false
          @nobreak_regex.each { |k, v| no_brk = ((words[i + 1] =~ /#{k}/) && (words[i] =~ /#{v}/)) }
          i -= 1
          break if not no_brk
        end
        if i > 0
          l = brk_re(i).match(line)
          line.sub!(brk_re(i), l[1])
          next_line = "#{l[2]} #{next_line}"
          line.sub!(/\s+$/, '')
        end
      end
      [line, next_line]
    end

    def __create(arg = nil, &block) #:nodoc:
        # Format::Text.new(text-to-wrap)
      @text = arg unless arg.nil?
        # Defaults
      @columns          = 72
      @tabstop          = 8
      @first_indent     = 4
      @body_indent      = 0
      @format_style     = LEFT_ALIGN
      @left_margin      = 0
      @right_margin     = 0
      @extra_space      = false
      @text             = Array.new if @text.nil?
      @tag_paragraph    = false
      @tag_text         = Array.new
      @tag_cur          = ""
      @abbreviations    = Array.new
      @nobreak          = false
      @nobreak_regex    = Hash.new
      @split_words      = Array.new
      @hard_margins     = false
      @split_rules      = SPLIT_FIXED
      @hyphenator       = self
      @hyphenator_arity = self.method(:hyphenate_to).arity

      instance_eval(&block) unless block.nil?
    end

  public
      # Formats text into a nice paragraph format. The text is separated
      # into words and then reassembled a word at a time using the settings
      # of this Format object. If a word is larger than the number of
      # columns available for formatting, then that word will appear on the
      # line by itself.
      #
      # If +to_wrap+ is +nil+, then the value of <tt>#text</tt> will be
      # worked on.
    def format(to_wrap = nil)
      to_wrap = @text if to_wrap.nil?
      if to_wrap.class == Array
        __format(to_wrap[0])
      else
        __format(to_wrap)
      end
    end

      # Considers each element of text (provided or internal) as a paragraph.
      # If <tt>#first_indent</tt> is the same as <tt>#body_indent</tt>, then
      # paragraphs will be separated by a single empty line in the result;
      # otherwise, the paragraphs will follow immediately after each other.
      # Uses <tt>#format</tt> to do the heavy lifting.
    def paragraphs(to_wrap = nil)
      to_wrap = @text if to_wrap.nil?
      __paragraphs([to_wrap].flatten)
    end

      # Centers the text, preserving empty lines and tabs.
    def center(to_center = nil)
      to_center = @text if to_center.nil?
      __center([to_center].flatten)
    end

      # Replaces all tab characters in the text with <tt>#tabstop</tt> spaces.
    def expand(to_expand = nil)
      to_expand = @text if to_expand.nil?
      if to_expand.class == Array
        to_expand.collect { |te| __expand(te) }
      else
        __expand(to_expand)
      end
    end

      # Replaces all occurrences of <tt>#tabstop</tt> consecutive spaces
      # with a tab character.
    def unexpand(to_unexpand = nil)
      to_unexpand = @text if to_unexpand.nil?
      if to_unexpand.class == Array
        to_unexpand.collect { |te| v << __unexpand(te) }
      else
        __unexpand(to_unexpand)
      end
    end

      # This constructor takes advantage of a technique for Ruby object
      # construction introduced by Andy Hunt and Dave Thomas (see reference),
      # where optional values are set using commands in a block.
      #
      #   Text::Format.new {
      #       columns         = 72
      #       left_margin     = 0
      #       right_margin    = 0
      #       first_indent    = 4
      #       body_indent     = 0
      #       format_style    = Text::Format::LEFT_ALIGN
      #       extra_space     = false
      #       abbreviations   = {}
      #       tag_paragraph   = false
      #       tag_text        = []
      #       nobreak         = false
      #       nobreak_regex   = {}
      #       tabstop         = 8
      #       text            = nil
      #   }
      #
      # As shown above, +arg+ is optional. If +arg+ is specified and is a
      # +String+, then arg is used as the default value of <tt>#text</tt>.
      # Alternately, an existing Text::Format object can be used or a Hash can
      # be used. With all forms, a block can be specified.
      #
      # *Reference*:: "Object Construction and Blocks"
      #               <http://www.pragmaticprogrammer.com/ruby/articles/insteval.html>
      #
    def initialize(arg = nil, &block)
      case arg
      when Text::Format
        __create(arg.text) do
          @columns        = arg.columns
          @tabstop        = arg.tabstop
          @first_indent   = arg.first_indent
          @body_indent    = arg.body_indent
          @format_style   = arg.format_style
          @left_margin    = arg.left_margin
          @right_margin   = arg.right_margin
          @extra_space    = arg.extra_space
          @tag_paragraph  = arg.tag_paragraph
          @tag_text       = arg.tag_text
          @abbreviations  = arg.abbreviations
          @nobreak        = arg.nobreak
          @nobreak_regex  = arg.nobreak_regex
          @text           = arg.text
          @hard_margins   = arg.hard_margins
          @split_words    = arg.split_words
          @split_rules    = arg.split_rules
          @hyphenator     = arg.hyphenator
        end
        instance_eval(&block) unless block.nil?
      when Hash
        __create do
          @columns       = arg[:columns]       || arg['columns']       || @columns
          @tabstop       = arg[:tabstop]       || arg['tabstop']       || @tabstop
          @first_indent  = arg[:first_indent]  || arg['first_indent']  || @first_indent
          @body_indent   = arg[:body_indent]   || arg['body_indent']   || @body_indent
          @format_style  = arg[:format_style]  || arg['format_style']  || @format_style
          @left_margin   = arg[:left_margin]   || arg['left_margin']   || @left_margin
          @right_margin  = arg[:right_margin]  || arg['right_margin']  || @right_margin
          @extra_space   = arg[:extra_space]   || arg['extra_space']   || @extra_space
          @text          = arg[:text]          || arg['text']          || @text
          @tag_paragraph = arg[:tag_paragraph] || arg['tag_paragraph'] || @tag_paragraph
          @tag_text      = arg[:tag_text]      || arg['tag_text']      || @tag_text
          @abbreviations = arg[:abbreviations] || arg['abbreviations'] || @abbreviations
          @nobreak       = arg[:nobreak]       || arg['nobreak']       || @nobreak
          @nobreak_regex = arg[:nobreak_regex] || arg['nobreak_regex'] || @nobreak_regex
          @hard_margins  = arg[:hard_margins]  || arg['hard_margins']  || @hard_margins
          @split_rules   = arg[:split_rules] || arg['split_rules'] || @split_rules
          @hyphenator    = arg[:hyphenator] || arg['hyphenator'] || @hyphenator
        end
        instance_eval(&block) unless block.nil?
      when String
        __create(arg, &block)
      when NilClass
        __create(&block)
      else
        raise TypeError
      end
    end
  end
end
