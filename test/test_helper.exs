# Truncate log files before test...
for handler_id <- :logger.get_handler_ids(),
    handler_id not in [:default, :ssl_handler] do
  {:ok, %{config: %{file: path}}} = :logger.get_handler_config(handler_id)
  # `File.rm/1` would prevent test logging when file_check > 0.
  {:ok, _pid} = File.open(path, [:write])
end

ExUnit.start()
