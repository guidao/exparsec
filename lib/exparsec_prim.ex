defmodule Exparsec.Prim do
  def oneof(input) do
    fn(x)->
      x in input 
    end
  end

  def noneof(input) do
    fn(x)->
      !(x in input)
    end
  end

end
