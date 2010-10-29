# This class extends from demo/ps_term_tbl to
# demo/test the accumulative mirror option
# It also tests that child classes effectively can override OracleToMysql options
# set in the parent
require 'ps_term_tbl'
class PsTermTblAccumulative < PsTermTbl
  # OVERRIDDEN from default to test :accumulative option
  def otm_strategy
    :accumulative
  end  
end