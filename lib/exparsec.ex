defmodule State do
  defstruct [:input, :reason]
end

defmodule Exparsec do
  require State
  require Exparsec.Combo
  import Exparsec.Combo
  import Exparsec.Prim

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
    first = (&letter/0) <|> (&symbol/0)
    rest = many((&letter/0) <|> (&digit/0) <|> (&symbol/0))
    rest = many(orelse(&letter/0, orelse(&digit/0, &symbol/0)))
    combo first, rest
  end

  def string do
    c = char '"'
    combo(c, combo(many(noneof('"')), c))
  end

  def space do
    return(oneof ' \t')
  end

  def spaces do
    many1(space)
  end
  def number do
    many1(digit)
  end

  def expr do
    kuo = char '('
    kuo2 = char ')'
    list = orelse(&parseList/0, &parseDottedList/0)
    com = combo(kuo, combo(list, kuo2))
    orelse(&atom/0, orelse(&string/0, orelse(&number/0, orelse(&parseQuote/0, com))))
  end

  def parseList do
    sepBy(&expr/0, &space/0)
  end

  def parseDottedList do
    head = endBy &expr/0, &spaces/0
    tail = combo(char('.'), combo(&spaces/0, &expr/0))
    combo head, tail
  end

  def parseQuote do
    combo(char('\''), &expr/0)
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
  def runP(fun, state) when is_function(fun) do
    runP(fun.(), state)
  end
  
  def parse(p, name , input) do
    runP(p, initState(input))
  end


  def initState(input) do
    %State{input: input}
  end


end

