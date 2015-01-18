require 'version_info'

module DebugMe
  VERSION = '1.0.1'
  include VersionInfo
  VERSION.file_name = __FILE__ 
end
