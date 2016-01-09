defmodule Exparsec.Util do
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
        [] ->
          {:error,"not match", state}
      end
    end}
  end

  def fix_return([_|_] = c, {:ok, val, state}) do
    {:ok, c ++ val, state}
  end
  def fix_return(c, {:ok, val, state}) do
    {:ok, [c|val], state}
  end
  def fix_return(c, {:error, reason, state}) do
    {:ok, [c], state}
  end

  def runP({:parser, f}, %State{}=state) do
    f.(state)
  end
  def runP(fun, state) when is_function(fun) do
    runP(fun.(), state)
  end

end
