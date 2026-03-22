defmodule Todo do
  @moduledoc """
  Handles ToDo state changes.

  Slice: View Add ToDo
  Type: STATE_CHANGE (Command)
  """

  defstruct [:id, :title, :completed]

  @doc """
  Creates a new ToDo item and returns a ToDo Added event.

  ## Examples

      iex> {:ok, event} = Todo.add_todo("Buy groceries")
      iex> event.type
      :todo_added
      iex> event.payload.title
      "Buy groceries"

  """
  def add_todo(title) when is_binary(title) and byte_size(title) > 0 do
    todo = %Todo{
      id: generate_id(),
      title: title,
      completed: false
    }

    event = %{
      type: :todo_added,
      payload: todo
    }

    {:ok, event}
  end

  def add_todo(_), do: {:error, :invalid_title}

  defp generate_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end
end
