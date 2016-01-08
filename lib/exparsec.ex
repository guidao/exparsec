defmodule State do
  defstruct [:input, :reason]
end

defmodule Exparsec do
  require State

  def return(fun) do
    {:parser, fn(state)->
      case state.input do
        [c|cs] ->
          case fun.(c) do
            true ->
              {:ok, [c], %State{state|input: cs}}
            false ->
              {:error, "not match", state}
          end
      end

    end}
  end

  def oneof(input) do
    fn(x)->
      x in input 
    end
  end

  def skipMany(test) do
    {:parser, fn(state)->
      case state.input do
        [c|cs] ->
          case test.(c) do
            true ->
              runP(skipMany(test), %State{state|input: cs})
            false ->
              {:ok, [], state}
          end
        [] ->
          {:ok, [], state} 
      end
    end}
  end

  def runP({:parser, f},%State{}=state) do
    f.(state)
  end
  
  def combo(p, x) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          runP(x, nstate)
        error ->
          error
      end

    end}
  end


  def parse(p, name , input) do
    runP(p, initState(input))
  end


  def initState(input) do
    %State{input: input}
  end


end

