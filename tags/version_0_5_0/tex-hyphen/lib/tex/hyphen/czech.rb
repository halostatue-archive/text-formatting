module TeX #:nodoc:
  class Hyphen #:nodoc:
      # = TeX::Hyphen::Czech
      #
      # Provides parsing routine for Czech patterns
      #
      # == Synopsis
      #   require 'tex/hyphen'
      #   hyp = TeX::Hyphen.new
      #     # Default hyphenation style is 'czech'
      #
      # == Description
      # This pattern processing happens to be the default. If you need to
      # write you own style of parsing the pattern file, you might want to
      # start with this file and hack it to suit your needs. There is nothing
      # for end users here -- just specify the style parameter in call to new
      # TeX::Hyphen.
      #
      # The language style specific modules have to define the following
      # functions:
      #
      # * process_patterns
      # * process_hyphenation
      #
      # Check the 'tex/hyphen/czech.rb' source to see the exact form of
      # the values inserted into these has structures.
      #
      # Each style module should also define DEFAULT_STYLE_MIN_LEFT and
      # DEFAULT_STYLE_MIN_RIGHT global variables, if they have different
      # values than the default 2. The values should match the paratemers used
      # to generate the patterns. Since various pattern files could be
      # generated with different values set, this is just a default that can
      # be changed with parameters to the TeX::Hyphen constructor.
      #
      # Note: the encoding for this is ISO-8859-1 or ISO-8859-15.
    module Czech
    private
      BACKV  = { 'c' => 'è', 'd' => 'ï', 'e' => 'ì', 'l' => 'µ', 'n' => 'ò',
                 'r' => 'ø', 's' => '¹', 't' => '»', 'z' => '¾', 'C' => 'È',
                 'D' => 'Ï', 'E' => 'Ì', 'L' => '¥', 'N' => 'Ò', 'R' => 'Ø',
                 'S' => '©', 'T' => '«', 'Z' => '®' }
      BACKAP = { 'a' => 'á', 'e' => 'é', 'i' => 'í', 'l' => 'å', 'o' => 'ó',
                 'u' => 'ú', 'y' => 'ı', 'A' => 'Á', 'E' => 'É', 'I' => 'Í',
                 'L' => 'Å', 'O' => 'Ó', 'U' => 'Ú', 'Y' => 'İ' }

      STYLE_VERSION = '0.121'

      DEFAULT_STYLE_MIN_LEFT  = 2
      DEFAULT_STYLE_MIN_RIGHT = 2

      def cstolower(e)
				e.tr('A-ZÁÄÈÏÉÌËÍÅ¥ÒÓÔÕÖØ©«ÚÙÛÜİ¬®', 'a-záäèïéìëíåµòóôõöø¹»úùûüı¼¾')
      end

        # This method gets individual lines of the \patterns content. It
        # should parse these lines, and fill values in @both_hyphen,
        # @begin_hyphen, @end_hyphen and @hyphen, members of the class. The
        # function should return false if end of the pattern section (macro)
        # was reached, 1 if the parsing should continue.
      def process_patterns(line)
        return false if (line =~ /\}/)

        line.split(/\s+/).each do |w|
          next if w.empty?

          start = stop = false

          start = true if w.sub!(/^\./, '')
          stop = true if w.sub!(/\.$/, '')

          w.gsub!(/\\v\s+(.)/) { BACKV[$1] }    # Process the \v tag
          w.gsub!(/\\'(.)/) { BACKAP[$1] }      # Process the \' tag
          w.gsub!(/\^\^(..)/) { $1.hex.to_s }  # convert things like ^^fc

          w.gsub!(/(\D)(?=\D)/) { "#{$1}0" }    # insert zeroes
          w.gsub!(/^(?=\D)/, '0')               # and start with some digit

          #tag = cstolower(w.gsub(/\d/, ''))     # get the lowercase string...
          tag = w.gsub(/\d/, '')
          value = w.gsub(/\D/, '')              # and numbers apart
          tag = cstolower(tag)
            # The Perl maintainers say: (if we knew locales were fine
            # everywhere, we could use them)

          if (start and stop)
						@both_hyphen[tag] = value
					elsif (start)
						@begin_hyphen[tag] = value
					elsif (stop)
						@end_hyphen[tag] = value
					else
						@hyphen[tag] = value
          end
        end
        true
      end

        # This method gets the lines of the \hyphenation content. It should
        # parse these lines and fill values into exception which is passed as
        # second parameter upon call. The function should return 0 if end of
        # the exception section (macro) was reached, 1 if the parsing should
        # continue.
      def process_hyphenation(line)
        return false if line =~ /\}/

        l = line.gsub(/\\v\s+(.)/) { BACKV[$1] }
        l.gsub!(/\\'(.)/) { BACKAP{$1} }
        tag = cstolower(l.gsub(/-/, ''))
        value = "0" + l.gsub(/[^-](?=[^-])/, '0').gsub(/[^-]-/, '1')
        value.gsub!(/[^01]/, '0')
        @exception[tag] = value
        true
      end
    end
  end
end
