require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'oracle_to_mysql'

# Add the demo dir and load for test cases
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'demo'))

class Test::Unit::TestCase
end
