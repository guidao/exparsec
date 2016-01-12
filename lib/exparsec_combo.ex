defmodule Exparsec.Combo do
  import Exparsec.Util

  def skipMany(p) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, _val, nstate} ->
          runP(skipMany(p), nstate)
        {:error, reason, nstate} ->
          {:ok, [], nstate}
      end
    end}
  end

  def skipMany1(p) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, _val, nstate} ->
          runP(skipMany(p), nstate)
        {:error, reason, nstate} ->
          {:error, reason, nstate}
      end
    end}
  end


  def many({:parser, _}=p) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          fix_return(val, runP(many(p), nstate))
        error ->
          error
      end
    end}
  end

  def many1(p) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          fix_return(val, runP(many(p), nstate))
        {:error, reason, nstate} ->
          {:error, reason, nstate}
      end
    end}
  end

  def sepBy(p, sep) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          case runP(sep, nstate) do
            {:ok, val2, nstate2} ->
              fix_return(val ++ val2, runP(sepBy(p, sep), nstate2))
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
  def combo(p, x) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:ok, val, nstate} ->
          fix_return(val, runP(x, nstate))
        {:error, val, nstate} ->
          {:error, val, nstate}
      end

    end}
  end

  defmacro p >>> x do
    quote do: combo(unquote(p), unquote(x))
  end

  def orelse(p, x) do
    {:parser, fn(state)->
      case runP(p, state) do
        {:error, "not match", state} ->
          runP(x, state)
        {:ok, val, nstate} ->
          {:ok, val, nstate}
      end
    end}
  end

  defmacro p <|> x do
    quote do: orelse(unquote(p), unquote(x))
  end
end
