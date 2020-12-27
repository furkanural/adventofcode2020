defmodule Day4 do
  def add_to_map(m, s) do
    pair = String.split(s, ":")
    Map.put(m, String.to_atom(Enum.at(pair, 0)), Enum.at(pair, 1))
  end

  def passport_information(str) do
    str
    |> lines_to_list()
    |> Enum.reduce(%{}, &add_to_map(&2, &1))
  end

  defp lines_to_list(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn x, acc ->
      String.split(x, " ", trim: true) ++ acc
    end)
  end

  def data_to_passport_information(str) do
    str
    |> String.split("\n")
    |> Enum.reduce(%{current: nil, passports: []}, fn x, acc ->
      case x do
        "" ->
          Map.get_and_update(acc, :passports, fn current_value ->
            {current_value, [Map.get(acc, :current) | current_value]}
          end)
          |> elem(1)
          |> Map.get_and_update(:current, fn current_value ->
            {current_value, nil}
          end)
          |> elem(1)

        _ ->
          Map.get_and_update(acc, :current, fn current_value ->
            {current_value, "#{current_value} #{x}"}
          end)
          |> elem(1)
      end
    end)
    |> Map.get(:passports)
    |> Enum.map(&passport_information/1)
    |> Enum.reverse()
  end

  def have_required_keys?(passport) do
    [:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]
    |> Enum.all?(&Map.has_key?(passport, &1))
  end

  def in_a_valid_range?(map, key, range) do
    val =
      map
      |> Map.get(key, 0)
      |> String.to_integer()

    Enum.member?(range, val)
  end

  def is_one_of_them?(map, key) do
    ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    |> Enum.member?(Map.get(map, key, ""))
  end

  def is_possible_height?(map, key) do
    val = Map.get(map, key)

    is_height_valid?(String.slice(val, 0..-3), String.slice(val, -2..-1))
  end

  defp is_height_valid?(val, unit) when unit == "in" do
    59..76
    |> Enum.member?(String.to_integer(val))
  end

  defp is_height_valid?(val, unit) when unit == "cm" do
    150..193
    |> Enum.member?(String.to_integer(val))
  end

  defp is_height_valid?(_, _), do: false

  def is_a_valid_color?(map, key) do
    val = Map.get(map, key)

    start_with = String.starts_with?(val, "#")

    is_six_digit = String.slice(val, 1..-1) |> String.length() == 6

    valid_values =
      val
      |> String.slice(1..-1)
      |> String.codepoints()
      |> Enum.filter(fn x ->
        Enum.member?(
          [
            "0",
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "a",
            "b",
            "c",
            "d",
            "e",
            "f"
          ],
          x
        )
      end)
      |> length() == 6

    start_with && is_six_digit && valid_values
  end

  def is_valid_passport_id?(map, key) do
    val = Map.get(map, key)

    String.length(val) == 9 && Regex.match?(~r{\A\d*\z}, val)
  end

  def is_a_valid_passport?(passport) do
    have_required_keys?(passport) && validate_field(passport, :byr)
  end

  defp validate_field(map, :byr) do
    case in_a_valid_range?(map, :byr, 1920..2002) do
      true ->
        validate_field(map, :iyr)

      _ ->
        false
    end
  end

  defp validate_field(map, :iyr) do
    case in_a_valid_range?(map, :iyr, 2010..2020) do
      true ->
        validate_field(map, :eyr)

      _ ->
        false
    end
  end

  defp validate_field(map, :eyr) do
    case in_a_valid_range?(map, :eyr, 2020..2030) do
      true ->
        validate_field(map, :hgt)

      _ ->
        false
    end
  end

  defp validate_field(map, :hgt) do
    case is_possible_height?(map, :hgt) do
      true ->
        validate_field(map, :hcl)

      _ ->
        false
    end
  end

  defp validate_field(map, :hcl) do
    case is_a_valid_color?(map, :hcl) do
      true ->
        validate_field(map, :ecl)

      _ ->
        false
    end
  end

  defp validate_field(map, :ecl) do
    case is_one_of_them?(map, :ecl) do
      true ->
        validate_field(map, :pid)

      _ ->
        false
    end
  end

  defp validate_field(map, :pid) do
    is_valid_passport_id?(map, :pid)
  end

  defp validate_field(_, _), do: false
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      import Day4

      test "parse tuple and add to map" do
        str = "pid:860033327"
        str2 = "eyr:2020"

        assert add_to_map(%{}, str) == %{pid: "860033327"}
        assert add_to_map(%{pid: "860033327"}, str2) == %{pid: "860033327", eyr: "2020"}
      end

      test "collect passport information" do
        str = """
        ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
        byr:1937 iyr:2017 cid:147 hgt:183cm
        """

        assert passport_information(str) == %{
                 ecl: "gry",
                 pid: "860033327",
                 eyr: "2020",
                 hcl: "#fffffd",
                 byr: "1937",
                 iyr: "2017",
                 cid: "147",
                 hgt: "183cm"
               }
      end

      test "Split data to passport information" do
        str = """
        iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
        hcl:#cfa07d byr:1929

        hcl:#ae17e1 iyr:2013
        eyr:2024
        ecl:brn pid:760753108 byr:1931
        hgt:179cm
        """

        assert data_to_passport_information(str) == [
                 %{
                   iyr: "2013",
                   ecl: "amb",
                   cid: "350",
                   eyr: "2023",
                   pid: "028048884",
                   hcl: "#cfa07d",
                   byr: "1929"
                 },
                 %{
                   hcl: "#ae17e1",
                   iyr: "2013",
                   eyr: "2024",
                   ecl: "brn",
                   pid: "760753108",
                   byr: "1931",
                   hgt: "179cm"
                 }
               ]
      end

      test "password have a required keys" do
        valid = %{
          ecl: "gry",
          pid: "860033327",
          eyr: "2020",
          hcl: "#fffffd",
          byr: "1937",
          iyr: "2017",
          cid: "147",
          hgt: "183cm"
        }

        valid_without_cid = %{
          hcl: "#ae17e1",
          iyr: "2013",
          eyr: "2024",
          ecl: "brn",
          pid: "760753108",
          byr: "1931",
          hgt: "179cm"
        }

        invalid = %{
          iyr: "2013",
          ecl: "amb",
          cid: "350",
          eyr: "2023",
          pid: "028048884",
          hcl: "#cfa07d",
          byr: "1929"
        }

        assert have_required_keys?(valid)

        assert have_required_keys?(valid_without_cid)

        assert have_required_keys?(invalid) == false
      end

      test "In a valid range" do
        valid = %{
          iyr: "2013"
        }

        invalid = %{
          iyr: "1990"
        }

        assert in_a_valid_range?(valid, :iyr, 2010..2020)
        assert in_a_valid_range?(invalid, :iyr, 2010..2020) == false
      end

      test "Is one of them include" do
        valid = %{
          ecl: "amb"
        }

        invalid = %{
          ecl: "inv"
        }

        assert is_one_of_them?(valid, :ecl)
        assert is_one_of_them?(invalid, :ecl) == false
      end

      test "Is it possible height" do
        valid = %{
          hgt: "190cm"
        }

        valid2 = %{
          hgt: "60in"
        }

        invalid = %{
          hgt: "190in"
        }

        invalid2 = %{
          hgt: "190"
        }

        assert is_possible_height?(valid, :hgt)
        assert is_possible_height?(valid2, :hgt)
        assert is_possible_height?(invalid, :hgt) == false
        assert is_possible_height?(invalid2, :hgt) == false
      end

      test "a # followed by exactly six characters 0-9 or a-f" do
        valid = %{
          hcl: "#123abc"
        }

        invalid = %{
          hcl: "#123abz"
        }

        invalid2 = %{
          hcl: "123abc"
        }

        assert is_a_valid_color?(valid, :hcl)
        assert is_a_valid_color?(invalid, :hcl) == false
        assert is_a_valid_color?(invalid2, :hcl) == false
      end

      test "a nine-digit number, including leading zeroes" do
        valid = %{
          pid: "000000001"
        }

        invalid = %{
          pid: "0123456789"
        }

        assert is_valid_passport_id?(valid, :pid)
        assert is_valid_passport_id?(invalid, :pid) == false
      end

      test "is a valid part-2" do
        invalid =
          """
          eyr:1972 cid:100
          hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926
          """
          |> data_to_passport_information()
          |> hd()

        invalid2 =
          """
          iyr:2019
          hcl:#602927 eyr:1967 hgt:170cm
          ecl:grn pid:012533040 byr:1946
          """
          |> data_to_passport_information()
          |> hd()

        invalid3 =
          """
          hcl:dab227 iyr:2012
          ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277
          """
          |> data_to_passport_information()
          |> hd()

        invalid4 =
          """
          hgt:59cm ecl:zzz
          eyr:2038 hcl:74454a iyr:2023
          pid:3556412378 byr:2007
          """
          |> data_to_passport_information()
          |> hd()

        valid =
          """
          pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
          hcl:#623a2f
          """
          |> data_to_passport_information()
          |> hd()

        valid2 =
          """
          eyr:2029 ecl:blu cid:129 byr:1989
          iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm
          """
          |> data_to_passport_information()
          |> hd()

        valid3 =
          """
          hcl:#888785
          hgt:164cm byr:2001 iyr:2015 cid:88
          pid:545766238 ecl:hzl
          eyr:2022
          """
          |> data_to_passport_information()
          |> hd()

        valid4 =
          """
          iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
          """
          |> data_to_passport_information()
          |> hd()

        assert is_a_valid_passport?(invalid) == false
        assert is_a_valid_passport?(invalid2) == false
        assert is_a_valid_passport?(invalid3) == false
        assert is_a_valid_passport?(invalid4) == false
        assert is_a_valid_passport?(valid)
        assert is_a_valid_passport?(valid2)
        assert is_a_valid_passport?(valid3)
        assert is_a_valid_passport?(valid4)
      end
    end

  _ ->
    {:ok, contents} = File.read("input_4.txt")

    contents
    |> Day4.data_to_passport_information()
    |> Enum.filter(&Day4.have_required_keys?/1)
    |> Enum.count()
    |> IO.inspect(label: "Part 1")

    contents
    |> Day4.data_to_passport_information()
    |> Enum.filter(&Day4.is_a_valid_passport?/1)
    |> Enum.count()
    |> IO.inspect(label: "Part 2")
end
