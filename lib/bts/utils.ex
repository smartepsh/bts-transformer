defmodule BTS.Utils do
  def read_xlsx(file_path, sheet \\ 0) do
    {:ok, pid, parser} = Exoffice.parse(file_path, sheet)

    data =
      pid
      |> Exoffice.get_rows(parser)
      |> Enum.to_list()

    Exoffice.close(pid, parser)

    data
  end
end
