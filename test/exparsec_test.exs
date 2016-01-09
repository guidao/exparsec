defmodule ExparsecTest do
  use ExUnit.Case
  doctest Exparsec

  import Exparsec
  import Exparsec.Combo
  import Exparsec.Prim
  import Exparsec.Util

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
    spaces = skipMany(return(space))
    read_expr spaces, '  '
    read_expr spaces, '    3'
    read_expr spaces, '1'
    number = return(oneof '0123456789')
    com = combo spaces, number
    read_expr com, '1    '
    read_expr com, '      3'
  end

  test "many" do
    n = oneof '1234567890'
    numbers = many(return(n))
    read_expr numbers, '123'
    read_expr numbers, 'a123'
    read_expr numbers, '123a'
  end

  test "string" do
    read_expr string, '"abcd"'
  end

  test "atom" do
    read_expr atom, 'abcd'
    read_expr atom, '$ab'
  end

  test "number" do
    read_expr number, 'a'
    read_expr number, '123'
    read_expr number, '12ad'
  end

  test "expr" do
    read_expr expr, 'abc'
    read_expr expr, '123'
    read_expr expr, '"adwe23gw"'
    read_expr expr, '(a b c)'
    read_expr expr, '(1 2 3)'
    read_expr expr, '(a b . c d)'
    read_expr expr, '\'(1 2 3)'
  end

  test "parseList" do
    read_expr parseList, 'ab cd ef'
    read_expr parseList, '12 34 ad'
    #read_expr parseList, '(12 ab)'
  end

end
