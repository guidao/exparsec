defmodule Exparsec.Prim do
  def oneof(input) do
    fn(x)->
      a = x in input 
      #IO.puts "input:#{inspect input}, x:#{inspect x}, bool:#{inspect a}"
      a
    end
  end

  def noneof(input) do
    fn(x)->
      a = !(x in input)
      #IO.puts "input:#{inspect input}, x:#{inspect x}, bool:#{inspect a}"
      a
    end
  end

end
