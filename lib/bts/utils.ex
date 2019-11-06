defmodule BTS.Utils do
  def env(key) do
    Application.get_env(:bts_transformer, key)
  end

  def env(key, sub_key) do
    Application.get_env(:bts_transformer, key, []) |> Keyword.get(sub_key)
  end

  def read_xlsx(file_path, sheet \\ 0) do
    {:ok, pid, parser} = Exoffice.parse(file_path, sheet)

    data =
      pid
      |> Exoffice.get_rows(parser)
      |> Enum.to_list()

    Exoffice.close(pid, parser)

    data
  end

  def read_csv_stream!(file_name) do
    file_name
    |> Path.expand(env(:public_path))
    |> File.stream!()
    |> CSV.decode!()
  end

  def write_xlsx(data, file_name \\ nil) do
    file_name =
      if file_name do
        file_name
      else
        {{_, month, day}, {hour, minute, second}} = DateTime.utc_now() |> NaiveDateTime.to_erl()

        "bts-#{month}_#{day}_#{hour}_#{minute}_#{second}"
      end

    path = Path.expand("#{file_name}.xlsx", env(:public_path))

    Elixlsx.write_to(data, path)
  end
end
