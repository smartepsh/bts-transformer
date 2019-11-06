defmodule BTS do
  @moduledoc """
  将收集到了数据表格，转换为目标格式，用于导入 BTS 系统。
  """

  @callback transform(String.t()) :: {:ok, String.t()} | {:error, atom()}

  def transform(file_name, target \\ "2019_H2") do
    mod =
      case target do
        "2019_H2" ->
          Y2019H2

        _ ->
          raise "not implement"
      end

    mod.transform(file_name)
  end
end
