Gem::Specification.new do |s|
  s.name = %q{tex-hyphen}
  s.version = %q{0.4.0}
  s.summary = %q{Hyphenates a word according to a TeX pattern file.}
  s.platform = Gem::Platform::RUBY

  s.has_rdoc = true

  s.test_files = %w{tests/tc_tex_hyphen.rb}

  s.autorequire = %q{tex/hyphen}
  s.require_paths = %w{lib}

  s.files = Dir.glob("**/*").delete_if do |item|
    item.include?("CVS") or item.include?(".svn") or
    item == "install.rb" or item =~ /~$/ or
    item =~ /gem(?:spec)?$/
  end

  s.author = %q{Martin DeMello, Austin Ziegler}
  s.email = %q{text-format@halostatue.ca}
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
