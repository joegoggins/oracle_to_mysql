require 'helper'

# test.demo is already in the load path, hence the omission of "demo/" here
# require 'ps_um_dept_tree'
# require 'job_queue_run'
require 'otm/ps/academic_program'
require 'otm/ps/academic_program_membership'
class TestBuilderApi < Test::Unit::TestCase


  context "Builder.configure, with DSL" do
    should "function" do
      OracleToMysql::Builder.configure do |config|
        config.build("Otm::Ps::AcademicProgram")
        config.build("Otm::Ps::AcademicProgramMembership")
      end
      assert_kind_of(OracleToMysql::Builder::NamespaceTree, OracleToMysql::Builder.root_tree)
      assert_equal(OracleToMysql::Builder.root_tree.name, :root_tree)
      assert_equal(OracleToMysql::Builder.root_tree.trees[0].args[0], "Otm::Ps::AcademicProgram")            
      assert_equal(OracleToMysql::Builder.root_tree.trees[1].args[0], "Otm::Ps::AcademicProgramMembership")            
    end
  end  
  
  context "Academic tree pathes basic linear BuildTree use case without DSL" do
    should "function" do
      @bt = OracleToMysql::Builder::BuildTree.new do |bt|
        bt.trees << OracleToMysql::Builder::BuildTree.new("Otm::Ps::AcademicProgram")
        bt.trees << OracleToMysql::Builder::BuildTree.new("Otm::Ps::AcademicProgramMembership")
      end
      assert_equal(@bt.mode, :linear, "The default mode is linear is unspecified")
      assert_kind_of(Array,@bt.args)
      assert_equal(@bt.trees[0].args[0], "Otm::Ps::AcademicProgram")            
      assert_equal(@bt.trees[1].args[0], "Otm::Ps::AcademicProgramMembership")
      # @bt.execute
    end
  end
  context "Be able to run .otm_execute on demo classes" do
    should "Only run this to test basic table building" do
      # Otm::Ps::AcademicProgram.new.otm_execute
      # Otm::Ps::AcademicProgramMembership.new.otm_execute
    end
  end
  
  
  context "Tree instantiation" do
    should "Be able to instantiate a build tree" do            
      @bt = OracleToMysql::Builder::BuildTree.new('Some::Class::Name')
      assert_kind_of(Array,@bt.args)
      assert_equal(@bt.name, nil)      
      assert_equal(@bt.args[0], 'Some::Class::Name')            
    end
  end
end
