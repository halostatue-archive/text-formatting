  # Note that this does not work as it should, yet. This is intended to put
  # the paragraph as:
  #
  # -+- I must go down to the sea again
  # -+- The lonely sea and sky
  # -+- And all I want is a tall ship
  # -+- And a star to steer me by
  #
  # Watch this file's results for whether this has been implemented yet.
require 'Text/Format'

f = Text::Format.new()

text = <<EOT
I must go down to the sea again
The lonely sea and sky
And all I want is a tall ship
And a star to steer me by
EOT

f.body_indent = 4
f.tag_paragraph = false

puts f.paragraphs(text.split(/\n/))

f.body_indent = 0
f.first_indent = 0
f.tag_paragraph = true
f.tag_text = ["-+-"] * text.count("\n")

puts f.paragraphs(text.split(/\n/))

