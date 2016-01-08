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

  def noneof(input) do
    fn(x)->
      !(x in input)
    end
  end

  def char(input) do
    input |> oneof |> return
  end

  def letter do
    return(oneof('abcdefghijklmnopkrstuvwxyz'))
  end

  def symbol do
    return(oneof '!$%&|*+ -/: <=? >@^_~#')
  end

  def digit do
    return(oneof '0123456789')
  end

  def atom do
    first = orelse letter, symbol
    rest = many(orelse(letter, orelse(digit, symbol)))
    combo first, rest
  end

  def string do
    c = char '"'
    combo(c, combo(many(noneof('"')), c))
  end

  def space do
    return(oneof ' \t')
  end

  def number do
    many1(digit)
  end

  def expr do
    orelse(atom, orelse(string, number))
  end

  def parseList do
    sepBy(expr, space)
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

  def many({:parser, _}=p) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          fix_return(val,runP(p, nstate))
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
              fix_return(c, runP(many(test), %State{state|input: cs}))
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
      case runP(p, state) do
        {:ok, val, nstate} ->
          fix_return(val, runP(many(p), nstate))
        error ->
          error
      end
    end}
  end

  def sepBy(p, sep) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          case runP(sep, nstate) do
            {:ok, val2, nstate2} ->
              fix_return(val++val2, runP(sepBy(p, sep), nstate2))
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
      case runP(sepBy(p, sep), state) do
        {:ok, val, nstate} ->
          case runP(sep, nstate) do
            {:ok, _, _} = ok ->
              fix_return(val, ok)
            error ->
              error
          end
        error ->
          error
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
  
  def runP({:parser, f},%State{}=state) do
    f.(state)
  end
  
  def combo(p, x) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          IO.puts "pval:#{inspect val}"
          runP(x, nstate)
        error ->
          error
      end

    end}
  end

  def orelse(p, x) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:error, "not match", state} ->
          runP(x, state)
        ok ->
          ok
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

