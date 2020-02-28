defmodule Proyecto1 do
  @moduledoc """
  Documentation for Proyecto1.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Proyecto1.hello()
      :world

  """
  def increment(actual_call, winner_number, telefone) do
    lock = Mutex.await(MyMutex, telefone)
    new_actual = {actual_call + 1, telefone}
    IO.puts(new_actual)
    new_actual
    Mutex.release(MyMutex, lock)
  end


  def call_center(winner_number, win) do
    actual_call = {0, 0}

    spawn(fn -> increment(actual_call, winner_number, 1) end)
    spawn(fn -> increment(actual_call, winner_number, 2) end)
    spawn(fn -> increment(actual_call, winner_number, 3) end)
    spawn(fn -> increment(actual_call, winner_number, 4) end)

    # No se como hacer las variables globales, toca preguntar mañana
  end
end
