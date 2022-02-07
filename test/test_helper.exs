# %{
#   debug: "./log/debug.log",
#   info:  "./log/info.log" ,
#   warn   "./log/info.log" ,
#   error: "./log/info.log"
# }
paths = %{
  debug: :application.get_env(:logger, :debug_log, nil)[:path],
  info: :application.get_env(:logger, :info_log, nil)[:path],
  warn: :application.get_env(:logger, :warn_log, nil)[:path],
  error: :application.get_env(:logger, :error_log, nil)[:path]
}

# Delete log files before test...
paths
|> Map.values()
|> Enum.reject(&is_nil/1)
|> Enum.each(&File.rm/1)

ExUnit.start()
