begin
  require 'install-pkg'
rescue
  require './install-pkg.rb'
end

include InstallPkg
package_name = "tex"
InstallPkg.install_pkg(package_name)

