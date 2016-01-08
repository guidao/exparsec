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


end
