Gem::Specification.new do |s|
  s.name = %q{text-format}
  s.version = %q{1.0.0}
  s.summary = %q{Text::Format formats fixed-width text nicely.}
  s.platform = Gem::Platform::RUBY

  s.has_rdoc = true

  s.test_suite_file = %w{tests/testall.rb}

  s.autorequire = %q{text/format}
  s.require_paths = %w{lib}

  s.files = Dir.glob("**/*").delete_if do |item|
    item.include?("CVS") or item.include?(".svn") or
    item == "install.rb" or item =~ /~$/ or
    item =~ /gem(?:spec)?$/
  end

  s.author = %q{Austin Ziegler}
  s.email = %q{text-format@halostatue.ca}
  s.rubyforge_project = %q(text-format)
  s.homepage = %q{http://rubyforge.org/projects/text-format}
  description = []
  File.open("README") do |file|
    file.each do |line|
      line.chomp!
      break if line.empty?
      description << "#{line.gsub(/\[\d\]/, '')}"
    end
  end
  s.description = description[2..-1].join(" ") 

  s.add_dependency('text-hyphen', '>~ 1.0.0')
end
