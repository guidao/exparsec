defmodule ExparsecTest do
  use ExUnit.Case
  doctest Exparsec
  import Exparsec

  test "the truth" do
    assert 1 + 1 == 2
  end
  
  def read_expr(m, input) do
    case parse(m, "lisp", input) do
      {:ok, value, remain} ->
        IO.puts "value:#{inspect value}, remain:#{inspect remain}"
      {:error, reason, remain} ->
        IO.puts "reason:#{inspect reason}, remain:#{inspect remain}"
    end
  end


  test "oneof" do
    #number = oneof '0123456789'
    #read_expr number, '0'
    #read_expr number, '12'
    #read_expr number, 'ab'
    assert 1 == 1
  end

  test "skipmany" do
    space = oneof ' \t'
    spaces = skipMany space
    read_expr spaces, '  '
    read_expr spaces, '    3'
    read_expr spaces, '1'
    number = return(oneof '0123456789')
    com = combo spaces, number
    read_expr com, '1    '
    read_expr com, '      3'
  end

  test "many" do
    number = oneof '1234567890'
    numbers = many number
    read_expr numbers, '123'
    read_expr numbers, 'a123'
    read_expr numbers, '123a'
  end

  test "string" do
    c = char '"'
    com = combo(c,combo(many(noneof('"')),c))
    read_expr com, '"abcd"'
  end

  test "atom" do
    first = orelse letter, symbol
    rest = many(orelse(letter, orelse(digit, symbol)))
    com = combo first, rest
    read_expr com, 'abcd'
    read_expr com, '$ab'
  end

  test "number" do
    number = many1(digit)
    read_expr number, 'a'
    read_expr number, '123'
    read_expr number, '12ad'
  end

end
