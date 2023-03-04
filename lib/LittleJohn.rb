
require_relative "LittleJohn/version"
require_relative "LittleJohn/collection"
require_relative "LittleJohn/config"
require_relative "LittleJohn/helpers"
require_relative "LittleJohn/mongodb"
require_relative "LittleJohn/smtp"
require_relative "LittleJohn/http"

# require_relative "LittleJohn/daemon"
# require_relative "LittleJohn/threadhandler"

## LittleJohn App Framework
# Extend your application with LittleJohn and its
#   features will be appended into your application.
#
# Example:
#   module YourApp
#     extend LittleJohn
#
#     YourApp.config # will now contain LittleJohn.config attributes/methods
#     YourApp.mdb    # will contain the LittleJohn MongoDB connector
#     # and so on...
#   end
#

module LittleJohn
  def self.extended(mod)
    puts "#{mod} extended with #{self}!"
    mod.extend(LittleJohn::Config)
    mod.initialize_config
  end
end
