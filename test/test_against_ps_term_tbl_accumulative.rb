require 'helper'
require 'ps_term_tbl_accumulative'
class TestAgainstPsTermTblAccumulative < Test::Unit::TestCase
  context "Test API against ps_term_tbl" do
    setup do
      @ps_term_tbl_inst = PsTermTblAccumulative.new
    end
    should "be able to invoke otm_execute" do
      @ps_term_tbl_inst.otm_execute
    end
  end
end
