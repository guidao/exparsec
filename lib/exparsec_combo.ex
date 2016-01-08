defmodule Exparsec.Combo do

  def skipMany(test) do
    {:parser, fn(state)->
      case state.input do
        [c|cs] ->
          case test.(c) do
            true ->
              Exparsec.runP(skipMany(test), %State{state|input: cs})
            false ->
              {:ok, [], state}
          end
        [] ->
          {:ok, [], state} 
      end
    end}
  end

  def many({:parser, _}=p) do
    {:parser, fn(state)->
      case Exparsec.runP(p, state) do
        {:ok, val, nstate} ->
          Exparsec.fix_return(val, Exparsec.runP(p, nstate))
        error ->
          error
      end
    end}
  end

  def many(test) do
    {:parser, fn(state)->
      case state.input do
        [c|cs] ->
          case test.(c) do
            true ->
              Exparsec.fix_return(c, Exparsec.runP(many(test), %State{state|input: cs}))
            false ->
              {:ok, [], state}
          end
        [] ->
          {:ok, [], state}
      end
    end}
  end

  def many1(p) do
    {:parser, fn(state)->
      case Exparsec.runP(p, state) do
        {:ok, val, nstate} ->
          Exparsec.fix_return(val, Exparsec.runP(many(p), nstate))
        error ->
          error
      end
    end}
  end

  def sepBy(p, sep) do
    {:parser, fn(state)->
      case Exparsec.runP(p, state) do
        {:ok, val, nstate} ->
          case Exparsec.runP(sep, nstate) do
            {:ok, val2, nstate2} ->
              Exparsec.fix_return(val++val2, Exparsec.runP(sepBy(p, sep), nstate2))
            {:error, reason, nstate2} ->
              {:ok, [], nstate2}
          end
        error ->
          error
      end
    end}
  end

  def endBy(p, sep) do
    {:parser, fn(state)->
      case Exparsec.runP(sepBy(p, sep), state) do
        {:ok, val, nstate} ->
          case Exparsec.runP(sep, nstate) do
            {:ok, _, _} = ok ->
              Exparsec.fix_return(val, ok)
            error ->
              error
          end
        error ->
          error
      end
    end}
  end
  def combo(p, x) do
    {:parser, fn(state)->
      case Exparsec.runP(p, state) do
        {:ok, val, nstate} ->
          IO.puts "pval:#{inspect val}"
          Exparsec.runP(x, nstate)
        error ->
          error
      end

    end}
  end

  def orelse(p, x) do
    {:parser, fn(state)->
      case Exparsec.runP(p, state) do
        {:error, "not match", state} ->
          Exparsec.runP(x, state)
        ok ->
          ok
      end
    end}
  end

end
