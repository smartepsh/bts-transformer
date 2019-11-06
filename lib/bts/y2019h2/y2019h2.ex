defmodule BTS.Y2019H2 do
  require Elixlsx
  alias BTS.Y2019H2.Meta
  alias BTS.Utils
  alias Elixlsx.{Sheet, Workbook}

  @behaviour BTS

  @impl true
  def transform(file_name, opts) do
    target_name = Keyword.get(opts, :file_name)

    stream =
      file_name
      |> Utils.read_csv_stream!()
      |> Stream.drop(2)

    total_count = Enum.count(stream)
    IO.puts("Total count: #{total_count}.")

    addition_sheet = addition_sheet(stream)

    workbook = %Workbook{sheets: [addition_sheet]}
    IO.puts("writing file ...")
    Utils.write_xlsx(workbook, target_name)
  end

  def addition_sheet(stream) do
    brands = Meta.brands()

    indicator_titles =
      Meta.indicator_types()
      |> Enum.reduce([], fn %{text: text}, acc ->
        titles = Enum.map(brands, &"#{text}_#{&1}")
        acc ++ titles
      end)

    image_words = Meta.image_words()

    image_titles =
      Enum.reduce(brands, [], fn brand, acc ->
        titles = Enum.map(image_words, &"#{brand}_#{&1}")
        acc ++ titles
      end)

    title = indicator_titles ++ image_titles

    data = transform_addition_data(stream)

    %Sheet{name: "Sheet1", rows: [title | data]}
  end

  def transform_addition_data(stream) do
    IO.puts("start transforming ...")

    brands = Meta.brands()
    indicators = Meta.indicator_types()
    image_words = Meta.image_words()
    image_source = Meta.image_source()

    stream
    |> Flow.from_enumerable()
    |> Flow.map(&do_transform_addition(&1, brands, indicators, image_words, image_source))
    |> Enum.to_list()
  end

  defp do_transform_addition([num, id | _] = data, brands, indicators, image_words, image_source) do
    IO.puts("transforming #{id} ing ...")

    data =
      indicators
      |> transform_indicator(brands, data)
      |> transform_images(image_words, image_source, brands, data)

    [num, id | data]
  end

  defp transform_indicator(indicators, brands, data) do
    Enum.reduce(indicators, [], fn %{range: ranges}, acc ->
      target_brands =
        ranges
        |> Enum.map(&Enum.at(data, &1 - 1))
        |> Enum.map(&trim_brand/1)

      result =
        Enum.map(brands, fn brand ->
          if brand in target_brands, do: 1, else: nil
        end)

      acc ++ result
    end)
  end

  defp transform_images(result, image_words, image_source, brands, data) do
    image_data = get_image_data(image_source, data)

    image_result =
      Enum.reduce(brands, [], fn brand, acc ->
        data = Enum.filter(image_data, &(&1.brand == brand))

        result =
          Enum.map(image_words, fn image_word ->
            result = Enum.find(data, &(&1.image == image_word))
            if result, do: result.value, else: nil
          end)

        acc ++ result
      end)

    result ++ image_result
  end

  defp get_image_data(image_source, data) do
    image_source
    |> Enum.chunk_every(68)
    |> Enum.reduce([], fn [word_item | groups], acc ->
      image_word = Enum.at(data, hd(word_item) - 1)

      if image_word == "" do
        acc
      else
        values =
          groups
          |> Enum.map(fn [idx, _, str] ->
            value = data |> Enum.at(idx - 1) |> to_integer()

            %{
              brand: get_brand(str),
              value: value,
              image: image_word
            }
          end)
          |> Enum.filter(&(&1.value < 4))

        values ++ acc
      end
    end)
  end

  defp trim_brand(name) do
    name |> String.split("png") |> List.last() |> String.trim()
  end

  defp get_brand(string) do
    string |> String.split("_") |> List.last()
  end

  defp to_integer(nil), do: nil
  defp to_integer(""), do: nil
  defp to_integer(integer), do: String.to_integer(integer)
end
