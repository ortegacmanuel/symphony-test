defmodule Hello do
  @moduledoc """
  A simple greeting module.
  """

  def greet(name) do
    "Hello, #{name}! Welcome to Symphony."
  end

  def farewell(name) do
    "Goodbye, #{name}! See you next time."
  end

  def count_chars(string) do
    String.length(string)
  end

  def reverse_words(string) do
    string
    |> String.split()
    |> Enum.reverse()
    |> Enum.join(" ")
  end

  def shout(string) do
    String.upcase(string)
  end
end
