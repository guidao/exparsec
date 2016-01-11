defmodule Exparsec.Util do
  def tokenPrim(fun) do
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

  def return(val) do
    {:parser, fn(state)->
      {:ok, val, state}
    end}
  end

  def bind(p, f) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          runP(f.(val), nstate)
        {:error, reason, nstate} ->
          {:error, reason, nstate}
      end
    end}
  end

 

  def fix_return([_|_] = c, {:ok, val, state}) do
    IO.puts "c:#{inspect c}, val:#{inspect val}"
    {:ok, c ++ val, state}
  end
  def fix_return(c, {:ok, val, state}) do
    IO.puts "c:#{inspect c}, val:#{inspect val}"
    {:ok, [c|val], state}
  end
  def fix_return(c, {:error, reason, state}) do
    IO.puts "c:#{inspect c}"
    {:ok, [c], state}
  end

  def runP({:parser, f}, %State{}=state) do
    f.(state)
  end
  def runP(fun, state) when is_function(fun) do
    runP(fun.(), state)
  end

end
