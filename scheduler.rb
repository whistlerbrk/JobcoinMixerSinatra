# load Rails env
require './mixer'
require './mix_request'
require 'concurrent'
require 'json'
require 'net/http'
require 'logger'

# flush output immediately or it'll get caught until buffer is full / proc exit
logger = Logger.new(STDOUT)
$stdout.sync = true

logger.info "Starting Jobcoin network monitor and task scheduling"

# launch three TimerTasks which fire immediately and then recur every 15 seconds

# monitor the Jobcoin network for deposits
monitor_task = Concurrent::TimerTask.new(execution_interval: 15, run_now: true) do |task|
  ActiveRecord::Base.connection_pool.with_connection do
    MixRequest.await_deposits
  end
end

# transfer from our deposit addresses to the main house account
transfer_task = Concurrent::TimerTask.new(execution_interval: 15, run_now: true) do |task|
  ActiveRecord::Base.connection_pool.with_connection do
    MixRequest.transfer_deposits
  end
end

# distribute back to the user-provided addresses
distribution_task = Concurrent::TimerTask.new(execution_interval: 15, run_now: true) do |task|
  ActiveRecord::Base.connection_pool.with_connection do
    MixRequest.disburse_deposits
  end
end

# just a simple observer to log any errors
class ErrorObserver
  def initialize(logger)
    @logger = logger
  end

  attr_accessor :logger

  def update(time, result, error)
    if result
    elsif error.is_a?(Concurrent::TimeoutError)
      logger.error "(#{time}) Execution timed out\n"
    else
      logger.error "(#{time}) Execution failed with error #{error}\n"
      logger.error error.message
      logger.error error.backtrace.join("\n")
    end
  end
end

# attach the observer
monitor_task.add_observer(ErrorObserver.new(logger))
transfer_task.add_observer(ErrorObserver.new(logger))
distribution_task.add_observer(ErrorObserver.new(logger))

# run the tasks
monitor_task.execute
transfer_task.execute
distribution_task.execute

# tasks are not in the main thread, so we sleep here to keep this proc alive
sleep while monitor_task.running? || transfer_task.running? || distribution_task.running?

logger.info "Closing scheduler and network monitor"
exit 0
