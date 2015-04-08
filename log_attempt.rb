# the time zone to use to determine the beginning/ending of any given day
TIME_ZONE          = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
TIME_ZONE_PACIFIC  = ActiveSupport::TimeZone['Pacific Time (US & Canada)']
TIME_ZONE_EARLIEST = ActiveSupport::TimeZone['Hawaii']
TIME_ZONE_LATEST   = ActiveSupport::TimeZone['Guam']

# Returns a formatted timestamp of the current time, in Pacific Time.
# @return [String] The formatted timestamp.
def get_timestamp
  "[#{(Time.now.in_time_zone(TIME_ZONE_PACIFIC)).strftime('%m/%d/%y %l:%M%p')}]"
end

# Logs a given message, using Rails.logger.info, prefixed with a timestamp for the current time.
# @param [String] message The message to log
# @return [FalseClass, TrueClass] The result of calling Rails.logger.info.
def log_info_with_timestamp(message)
  Rails.logger.info ("#{get_timestamp} #{message}")
end

# Logs a given error message, using Rails.logger.error, prefixed with a timestamp for the current time.
# @param [String] message The error message to log.
# @return [String] Logs the given error
def log_error_with_timestamp(message)
  Rails.logger.error ("#{get_timestamp} #{message}")
end

# Logs the text and backtrace of a given exception, with a timestamp for the current time, using
# Rails.logger.error.
# @param [Exception] e The exception whose information is to be logged.
def log_exception(e)
  unless e.blank?
    log_error_with_timestamp e.inspect unless e.inspect.blank?
    log_error_with_timestamp e.backtrace.join("\n    ") unless e.backtrace.blank?
  end
end

# Executes the given block, first printing out "<message> ..." (if the 'message' argument was given.) If execution
# of the block succeeds, prints out "DONE <message>; result = ..." where ... is the result returned by the block. If
# execution of the block fails, prints out "ERROR <message>; result = ..." where ... is the value of the
# "return_on_fail" argument (nil by default.) If +:raise+ is passed in for "return_on_fail" and execution fails, the
# error message is still printed, but the exception is re-thrown.
# @param [String] message The message describing the action taken in the passed in block; will be printed out before
#   and after the execution of the block.
# @param [Object] return_on_fail The value to be returned if execution of the given block fails with an exception (if
#   +:raise+ is passed for this argument, the exception is re-thrown.)
# @return [Object] The result of executing the given block, or the value passed to the "return_on_fail" argument, if
#   execution of the block failed.
def log_attempt(message='', return_on_fail=nil)
  begin
    r = 'unknown'
    error = false
    log_info_with_timestamp "#{message} ..." unless message.blank?
    r = yield
  rescue StandardError => e
    error = true
    log_exception(e)
    log_error_with_timestamp "ERROR #{message}; result = #{return_on_fail.to_s[0,100]}" unless message.blank?
    if return_on_fail == :raise
      raise(e)
    else
      return_on_fail
    end
  ensure
    unless error
      log_info_with_timestamp "DONE #{message}; result = #{r.to_s[0,100]}" unless message.blank?
    end
  end
end