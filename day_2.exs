defmodule Day2 do
  def parse_line(line) do
    pattern = :binary.compile_pattern(["-", " ", ": "])
    splited = String.split(line, pattern)

    %{
      rule: %{
        min: String.to_integer(Enum.at(splited, 0)),
        max: String.to_integer(Enum.at(splited, 1))
      },
      letter: Enum.at(splited, 2),
      password: Enum.at(splited, 3)
    }
  end

  def is_valid_password_part_one?(%{rule: rule, password: password, letter: letter}) do
    password
    |> String.codepoints()
    |> Enum.filter(&(&1 == letter))
    |> Enum.count()
    |> is_in_range?(rule)
  end

  def is_valid_password_part_two?(%{
        rule: %{min: f, max: s},
        password: p,
        letter: l
      }) do
    chars = String.codepoints(p)

    is_in_first_position(chars, l, f - 1, s - 1) ||
      is_in_second_position(chars, l, f - 1, s - 1)
  end

  defp is_in_first_position(characters, letter, first, second) do
    Enum.at(characters, first) == letter &&
      Enum.at(characters, second) != letter
  end

  defp is_in_second_position(characters, letter, first, second) do
    Enum.at(characters, first) != letter &&
      Enum.at(characters, second) == letter
  end

  defp is_in_range?(count, %{min: min, max: max}) when count in min..max, do: true
  defp is_in_range?(_, _), do: false

  def valid_passwords_part_one(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.filter(&is_valid_password_part_one?/1)
    |> Enum.count()
  end

  def valid_passwords_part_two(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.filter(&is_valid_password_part_two?/1)
    |> Enum.count()
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case

      import Day2

      test "Parsing the line as rule and password" do
        line = "1-3 a: abcde"
        parsed_line = %{rule: %{min: 1, max: 3}, letter: "a", password: "abcde"}
        assert parse_line(line) == parsed_line

        line = "1-3 b: cdefg"
        parsed_line = %{rule: %{min: 1, max: 3}, letter: "b", password: "cdefg"}
        assert parse_line(line) == parsed_line

        line = "2-9 c: ccccccccc"
        parsed_line = %{rule: %{min: 2, max: 9}, letter: "c", password: "ccccccccc"}
        assert parse_line(line) == parsed_line
      end

      test "Is the password according to the rule?" do
        parsed_line = %{rule: %{min: 2, max: 9}, letter: "c", password: "ccccccccc"}
        assert is_valid_password_part_one?(parsed_line)

        parsed_line = %{rule: %{min: 1, max: 3}, letter: "b", password: "cdefg"}
        assert is_valid_password_part_one?(parsed_line) == false
      end

      test "How many passwords are valid according to their policies for part one?" do
        passwords = """
        1-3 a: abcde
        1-3 b: cdefg
        2-9 c: ccccccccc
        """

        assert valid_passwords_part_one(passwords) == 2
      end

      test "Is the password according to the rule for part two?" do
        parsed_line = %{rule: %{min: 1, max: 3}, letter: "a", password: "abcde"}
        assert is_valid_password_part_two?(parsed_line)

        parsed_line = %{rule: %{min: 1, max: 3}, letter: "a", password: "cbade"}
        assert is_valid_password_part_two?(parsed_line)

        parsed_line = %{rule: %{min: 1, max: 3}, letter: "b", password: "cdefg"}
        assert is_valid_password_part_two?(parsed_line) == false

        parsed_line = %{rule: %{min: 2, max: 9}, letter: "c", password: "ccccccccc"}
        assert is_valid_password_part_two?(parsed_line) == false
      end

      test "How many passwords are valid according to their policies for part two?" do
        passwords = """
        1-3 a: abcde
        1-3 b: cdefg
        2-9 c: ccccccccc
        """

        assert valid_passwords_part_two(passwords) == 1
      end
    end

  _ ->
    {:ok, contents} = File.read("passwords.txt")

    contents
    |> Day2.valid_passwords_part_one()
    |> IO.inspect(label: "part one valid passwords")

    contents
    |> Day2.valid_passwords_part_two()
    |> IO.inspect(label: "part two valid passwords")
end
