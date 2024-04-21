# Whether to run in single mode or cluster mode.
mode = ENV['PUMA_MODE'] || 'single'

# Server address bind configuration.
bind_address = ENV['PUMA_BIND_ADDRESS'] || '127.0.0.1'
bind_port = ENV['PUMA_BIND_PORT'] || 3000
bind = "tcp://#{bind_address}:#{bind_port}"

# Configure defaults based on mode.
if mode == 'single'
  workers = 0
  threads_min = ENV['PUMA_THREADS_MIN']&.to_i || 1
  threads_max = ENV['PUMA_THREADS_MAX']&.to_i || 1
  preload_app = ENV['PUMA_PRELOAD_APP'].nil? ? false : ENV['PUMA_PRELOAD_APP'] == 'true'
else
  workers = ENV['PUMA_WORKERS']&.to_i || 3
  threads_min = ENV['PUMA_THREADS_MIN']&.to_i || 2
  threads_max = ENV['PUMA_THREADS_MAX']&.to_i || 2
  preload_app = ENV['PUMA_PRELOAD_APP'].nil? ? true : ENV['PUMA_PRELOAD_APP'] == 'true'
end

# Disable queue requests if running with a single thread.
queue_requests = ENV['PUMA_DISABLE_QUEUE_REQUESTS'] != 'true' && threads_max > 1

# Perform configuration via Puma DSL.
bind bind
workers workers
threads threads_min, threads_max
preload_app! if preload_app
queue_requests queue_requests

on_booted do
  # Log configuration.
  Rails.logger.info "[puma] Mode: #{mode}"
  Rails.logger.info "[puma] Bind: #{bind}"
  Rails.logger.info "[puma] Workers: #{workers}"
  Rails.logger.info "[puma] Threads min: #{threads_min}"
  Rails.logger.info "[puma] Threads max: #{threads_max}"
  Rails.logger.info "[puma] Preload: #{preload_app}"
  Rails.logger.info "[puma] Queue requests: #{queue_requests}"
end
