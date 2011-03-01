# This class extends from demo/ps_term_tbl to
# demo/test the accumulative mirror option
# It also tests that child classes effectively can override OracleToMysql options
# set in the parent
require 'ps_term_tbl'

class PsTermTblWithRetain3 < PsTermTbl
  def otm_number_of_tables_to_retain
    3
  end
end
