defmodule Day5 do
  def decode_boarding(code) do
    %{
      row: code |> String.slice(0..6) |> String.codepoints() |> decode_boarding(0, 127),
      column: code |> String.slice(7..9) |> String.codepoints() |> decode_boarding(0, 7)
    }
  end

  def seat_id(%{row: row, column: column}), do: row * 8 + column

  def empty_seats(ids, lower_id, upper_id) do
    Enum.filter(lower_id..upper_id, fn x -> !Enum.member?(ids, x) end)
  end

  def empty_seats(ids) do
    sorted_ids = Enum.sort(ids)

    empty_seats(sorted_ids, Enum.min(sorted_ids), Enum.max(sorted_ids))
  end

  defp decode_boarding([x | codepoints], lower, upper) when x == "F" or x == "L" do
    decode_boarding(codepoints, lower, lower + floor((upper - lower) / 2))
  end

  defp decode_boarding([x | codepoints], lower, upper) when x == "B" or x == "R" do
    decode_boarding(codepoints, lower + ceil((upper - lower) / 2), upper)
  end

  defp decode_boarding([], lower, _upper), do: lower
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case

      import Day5

      test "Decode boarding code with the binary space partitioning" do
        assert decode_boarding("FBFBBFFRLR") == %{row: 44, column: 5}
        assert decode_boarding("BFFFBBFRRR") == %{row: 70, column: 7}
        assert decode_boarding("FFFBBBFRRR") == %{row: 14, column: 7}
        assert decode_boarding("BBFFBBFRLL") == %{row: 102, column: 4}
      end

      test "Find seat ID" do
        assert seat_id(%{row: 44, column: 5}) == 357
        assert seat_id(%{row: 70, column: 7}) == 567
        assert seat_id(%{row: 14, column: 7}) == 119
        assert seat_id(%{row: 102, column: 4}) == 820
      end

      test "find empty seats" do
        assert empty_seats([1, 2, 3, 5, 6, 7, 9], 1, 9) == [4, 8]
      end
    end

  _ ->
    {:ok, contents} = File.read("input_5.txt")

    contents
    |> String.split("\n", trim: true)
    |> Stream.map(&Day5.decode_boarding/1)
    |> Stream.map(&Day5.seat_id/1)
    |> Enum.max()
    |> IO.inspect(label: "Part 1")

    contents
    |> String.split("\n", trim: true)
    |> Stream.map(&Day5.decode_boarding/1)
    |> Stream.map(&Day5.seat_id/1)
    |> Day5.empty_seats()
    |> List.first()
    |> IO.inspect(label: "Part 2")
end
