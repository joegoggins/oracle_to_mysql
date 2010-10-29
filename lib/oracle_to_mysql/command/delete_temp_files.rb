module OracleToMysql
  class Command
    class DeleteTempFiles < OracleToMysql::Command              
      def execute_internal
        self.client_class.all_temp_files.each do |temp_file|
          begin
            self.info("Deleting temp file, #{temp_file}")
            File.unlink(temp_file)
          rescue Errno::ENOENT => e
            self.warn("Could not remove temp file #{temp_file}")
          end                      
        end
      end
    end
  end
end