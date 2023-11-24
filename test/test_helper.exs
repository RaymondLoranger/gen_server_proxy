env = :application.get_env(:file_only_logger, :logger, [])

# Truncate log files before test...
for {:handler, _handler_id, :logger_std_h, %{config: %{file: path}}} <- env,
    # `File.rm/1` would prevent test logging when file_check > 0.
    do: File.open(path, [:write])

ExUnit.start()
