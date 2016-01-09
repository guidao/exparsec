defmodule State do
  defstruct [:input, :reason]
end

defmodule Exparsec do
  require State
  require Exparsec.Combo
  import Exparsec.Combo
  import Exparsec.Prim
  import Exparsec.Util

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
    first >>> rest
  end

  def string do
    c = char '"'
    str = noneof('"') |> return
    c >>> str >>> c
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
    left = char '('
    right = char ')'

    list = (&parseList/0) <|> (&parseDottedList/0)
    com = left >>> list >>> right

    (&atom/0) <|> (&string/0) <|> (&number/0) <|> (&parseQuote/0) <|> com
  end

  def parseList do
    sepBy(&expr/0, &space/0)
  end

  def parseDottedList do
    head = endBy &expr/0, &spaces/0
    tail = char('.') >>> (&spaces/0) >>> (&expr/0)
    head >>> tail
  end

  def parseQuote do
    char('\'') >>> (&expr/0)
  end



  def parse(p, name , input) do
    runP(p, initState(input))
  end


  def initState(input) do
    %State{input: input}
  end

end

