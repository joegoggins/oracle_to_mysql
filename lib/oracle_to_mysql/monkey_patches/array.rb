module OracleToMysql::MonkeyPatches::Array
  def extract_options!  # from rails 2.3.5
    last.is_a?(::Hash) ? pop : {}
  end
end