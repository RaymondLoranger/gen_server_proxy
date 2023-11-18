env = Application.get_env(:file_only_logger, :logger)

# Delete log files before test...
for {:handler, _handler_id, :logger_std_h, %{config: %{file: path}}} <- env,
    do: File.rm(path)

# Maybe wait to ensure reading file information prior to writing.
case for {:handler, _, _, %{config: %{file_check: file_check_in_ms}}} <- env,
         do: file_check_in_ms do
  [] -> :ok
  file_checks_in_ms -> :ok = Enum.max(file_checks_in_ms) |> Process.sleep()
end

ExUnit.start()
