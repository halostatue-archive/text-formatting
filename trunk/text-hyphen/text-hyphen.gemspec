Gem::Specification.new do |s|
  s.name = 'tex-hyphen'
  s.version = '1.0.0'
  s.summary = %q(Multilingual word hyphenation according to modified TeX hyphenation pattern files.)
  s.platform = Gem::Platform::RUBY

  s.has_rdoc          = true
  s.rdoc_options      = %w(--title Text::Hyphen --main README --line-numbers)
  s.extra_rdoc_files  = %w(README LICENCE INSTALL ChangeLog)

  s.test_files        = %w{tests/tc_text_hyphen.rb}

  s.autorequire = %q{text/hyphen}
  s.require_paths = %w{lib}
  s.bindir = %q(bin)

  s.files = Dir.glob("**/*").delete_if do |item|
    item.include?("CVS") or item.include?(".svn") or
    item == "install.rb" or item =~ /~$/ or
    item =~ /gem(?:spec)?$/
  end

  s.author = %q{Austin Ziegler}
  s.email = %q{text-hyphen@halostatue.ca}
  s.rubyforge_project = %q(text-format)
  s.homepage = %q{http://rubyforge.org/projects/text-format/}
  description = []
  File.open("README") do |file|
    file.each do |line|
      line.chomp!
      break if line.empty?
      description << "#{line.gsub(/\[\d\]/, '')}"
    end
  end
  s.description = description[2..-1].join(" ")
end
