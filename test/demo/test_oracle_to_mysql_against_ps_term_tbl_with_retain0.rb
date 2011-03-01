require 'helper'

# test.demo is already in the load path, hence the omission of "demo/" here
# require 'ps_um_dept_tree'
# require 'job_queue_run'
require 'ps_term_tbl_with_retain0'
class TestOracleToMysql < Test::Unit::TestCase
  context "Test API against ps_term_tbl" do
    setup do
      @ps_term_tbl_inst = ::PsTermTblWithRetain0.new
    end
    
    should "be able to invoke otm_execute" do
      @ps_term_tbl_inst.otm_execute
    end
  end
end
