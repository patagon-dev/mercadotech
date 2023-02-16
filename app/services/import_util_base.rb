module ImportUtilBase
  BATCH_SIZE         = 100
  PROGRAM_SLEEP_TIME = 5

  def log_data(error_type, data)
    error_type = error_type.to_s

    @import_errors[error_type] ||= []
    @import_errors[error_type] << data
  end

  ## Create file, initalize and add logs
  def write_log_file
    file = File.open(self.class::ERROR_LOG_FILE, 'w')
    file.write(JSON.pretty_generate(@import_errors))
    file.close
  end
end
