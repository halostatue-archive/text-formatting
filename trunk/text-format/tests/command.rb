$:.unshift "../lib"

require 'text/format'
require 'tex/hyphen'

  # This requires "In the Beginning was the Command Line" by Neal Stephenson.
  # This is NOT included in the distribution.
  #       http://www.cryptonomicon.com/beginning.html
if not File.exist?('command.txt')
  puts Text::Format.new("The file 'command.txt' was not found. Please download it from http://www.cryptonomicon.com/beginning.html to run this test.").format
  exit
end

text = IO.readlines('command.txt')
textarr = []
data = nil

text.each do |line|
  if line =~ /^\s*$/
    textarr << data unless data.nil?
    data = nil
    next
  end

  if data.nil?
    data = line
  else
    data << line
  end
end

fmt = Text::Format.new(:columns => 38,
                       :format_style => Text::Format::RIGHT_FILL,
                       :hard_margins => true)

File.open("output1.txt", "w") { |f| f << fmt.paragraphs(textarr) }

fmt.split_rules = Text::Format::SPLIT_CONTINUATION

File.open("output2.txt", "w") { |f| f << fmt.paragraphs(textarr) }

fmt.hyphenator = TeX::Hyphen.new
fmt.split_rules = Text::Format::SPLIT_HYPHENATION

File.open("output3.txt", "w") { |f| f << fmt.paragraphs(textarr) }
