defmodule Day3 do
  def convert_to_matrix(map) do
    map
    |> String.split("\n", trim: true)
    |> Enum.map(&String.codepoints/1)
  end

  def find_starting_position([h | _]), do: find_starting_point(h, {0, 0})

  defp find_starting_point([h | t], {x, y}) when h == "#", do: find_starting_point(t, {x + 1, y})
  defp find_starting_point([h | _], point) when h == ".", do: point

  def find_steps(%{map: [_ | []], point: p, current: c, steps: s, shift: _}) do
    [%{point: p, val: c} | s] |> Enum.reverse()
  end

  def find_steps(%{map: m, point: p, current: c, steps: s, shift: {_, y} = shift}) do
    t = Enum.drop(m, y)
    %{new_point: np, val: v} = find_next_point(t, p, shift)

    find_steps(%{
      map: t,
      point: np,
      current: v,
      steps: [%{point: p, val: c} | s],
      shift: shift
    })
  end

  defp find_next_point([row | _], {x, y}, {shift_right, shift_down}) do
    val = row |> Enum.at(rem(x + shift_right, length(row)))

    %{new_point: {rem(x + shift_right, length(row)), y + shift_down}, val: val}
  end

  def solve_part_one(map) do
    matrix = convert_to_matrix(map)
    p = find_starting_position(matrix)

    find_steps(%{map: matrix, point: p, current: ".", steps: [], shift: {3, 1}})
    |> Enum.filter(&(&1[:val] == "#"))
    |> Enum.count()
  end

  def solve_part_two(map, shifts) when is_list(shifts) do
    shifts
    |> Enum.map(fn s -> solve_part_two(map, s) end)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def solve_part_two(map, shift) do
    matrix = convert_to_matrix(map)
    p = find_starting_position(matrix)

    find_steps(%{map: matrix, point: p, current: ".", steps: [], shift: shift})
    |> Enum.filter(&(&1[:val] == "#"))
    |> Enum.count()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      import Day3

      test "Convert string to matrix" do
        map = """
        #.##.
        #...#
        .#...
        ..#.#
        """

        assert convert_to_matrix(map) == [
                 ["#", ".", "#", "#", "."],
                 ["#", ".", ".", ".", "#"],
                 [".", "#", ".", ".", "."],
                 [".", ".", "#", ".", "#"]
               ]
      end

      test "Find starting position" do
        map = [
          ["#", ".", "#", "#", "."],
          ["#", ".", ".", ".", "#"],
          [".", "#", ".", ".", "."],
          [".", ".", "#", ".", "#"]
        ]

        assert find_starting_position(map) == {1, 0}
      end

      test "Find steps" do
        map = """
        ..##.......
        #...#...#..
        .#....#..#.
        ..#.#...#.#
        .#...##..#.
        ..#.##.....
        .#.#.#....#
        .#........#
        #.##...#...
        #...##....#
        .#..#...#.#
        """

        assert find_steps(%{
                 map: convert_to_matrix(map),
                 point: {0, 0},
                 current: ".",
                 steps: [],
                 shift: {3, 1}
               }) ==
                 [
                   %{point: {0, 0}, val: "."},
                   %{point: {3, 1}, val: "."},
                   %{point: {6, 2}, val: "#"},
                   %{point: {9, 3}, val: "."},
                   %{point: {1, 4}, val: "#"},
                   %{point: {4, 5}, val: "#"},
                   %{point: {7, 6}, val: "."},
                   %{point: {10, 7}, val: "#"},
                   %{point: {2, 8}, val: "#"},
                   %{point: {5, 9}, val: "#"},
                   %{point: {8, 10}, val: "#"}
                 ]
      end

      test "Solve part one" do
        map = """
        ..##.......
        #...#...#..
        .#....#..#.
        ..#.#...#.#
        .#...##..#.
        ..#.##.....
        .#.#.#....#
        .#........#
        #.##...#...
        #...##....#
        .#..#...#.#
        """

        assert solve_part_one(map) == 7
      end

      test "Right 1, down 1" do
        map = """
        ..##.......
        #...#...#..
        .#....#..#.
        ..#.#...#.#
        .#...##..#.
        ..#.##.....
        .#.#.#....#
        .#........#
        #.##...#...
        #...##....#
        .#..#...#.#
        """

        assert solve_part_two(map, {1, 1}) == 2
      end

      test "Right 1, down 2" do
        map = """
        ..##.......
        #...#...#..
        .#....#..#.
        ..#.#...#.#
        .#...##..#.
        ..#.##.....
        .#.#.#....#
        .#........#
        #.##...#...
        #...##....#
        .#..#...#.#
        """

        assert solve_part_two(map, {1, 2}) == 2
      end

      test "Solve part two" do
        map = """
        ..##.......
        #...#...#..
        .#....#..#.
        ..#.#...#.#
        .#...##..#.
        ..#.##.....
        .#.#.#....#
        .#........#
        #.##...#...
        #...##....#
        .#..#...#.#
        """

        assert solve_part_two(map, [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]) == 336
      end
    end

  _ ->
    {:ok, contents} = File.read("input_3.txt")

    contents
    |> Day3.solve_part_one()
    |> IO.inspect(label: "Part 1")

    contents
    |> Day3.solve_part_two([{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}])
    |> IO.inspect(label: "Part 2")
end
