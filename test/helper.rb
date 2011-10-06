require 'rubygems'
require 'bundler'
Bundler.setup
require 'shoulda'
require 'oracle_to_mysql'

module OracleToMysql
  module OptionalOverrideInstanceMethods
    def otm_config_file
      File.join(File.dirname(__FILE__), 'oracle_to_mysql.yml')
    end
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'demo'))

class Test::Unit::TestCase
end
