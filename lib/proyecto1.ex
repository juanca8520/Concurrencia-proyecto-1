# This module is in charge of the agent implemented to know what the number of answered calls is.
defmodule Counter do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  # This function is in charge of retrieving the number of answered calls.
  def value do
    Agent.get(__MODULE__, & &1)
  end

  # This function is in charge of incrementing the number of calls answered when invoked.
  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end
end

defmodule Proyecto1 do
  children = [
    {Mutex, name: MyMutex}
  ]

  {:ok, __} = Supervisor.start_link(children, strategy: :one_for_one)

  # This functions simulates the generation of the call, it is also in charge of telling who the winner call is.
  # It is important to mention that specific number is the randomly generated number
  def call(caller, specificNumber) do
    counter_id = {User, {:id, 1}}
    lock = Mutex.await(MyMutex, counter_id)
    Counter.increment()
    currentCall = Counter.value()

    if specificNumber == currentCall do
      IO.inspect("[#{caller}] You are the winner")
      Mutex.release(MyMutex, lock)
    else
      if specificNumber > currentCall do
        IO.inspect("[#{caller}] Keep Trying")
        Mutex.release(MyMutex, lock)
      else
        IO.inspect("[#{caller}] someone already won")
        Mutex.release(MyMutex, lock)
      end
    end
  end

  Counter.start_link(0)

  # This function is in charge of randomly selecting a phone to answer the incoming call
  def accept_call(actual_caller, specificNumber) do
    phone1_id = {User, {:id, 2}}
    phone2_id = {User, {:id, 3}}
    phone3_id = {User, {:id, 4}}
    phone4_id = {User, {:id, 5}}
    phone_assigned = :rand.uniform(4)

    case phone_assigned do
      1 ->
        # The mutex is used here to prevent processes form being created meanwhile other processes assosiated
        # with the given phone havent finished.
        lock = Mutex.await(MyMutex, phone1_id)
        spawn(fn -> call(actual_caller, specificNumber) end)
        Mutex.release(MyMutex, lock)

      2 ->
        lock2 = Mutex.await(MyMutex, phone2_id)
        spawn(fn -> call(actual_caller, specificNumber) end)
        Mutex.release(MyMutex, lock2)

      3 ->
        lock3 = Mutex.await(MyMutex, phone3_id)
        spawn(fn -> call(actual_caller, specificNumber) end)
        Mutex.release(MyMutex, lock3)

      4 ->
        lock4 = Mutex.await(MyMutex, phone4_id)
        spawn(fn -> call(actual_caller, specificNumber) end)
        Mutex.release(MyMutex, lock4)
    end
  end

  # This function is in charge of generating the calls for the phones to answer.
  def generate_calls(actual_caller, specificNumber) do
    # Timer
    # Process.sleep(:rand.uniform(10))
    accept_call(actual_caller + 1, specificNumber)

    if actual_caller < 200 do
      generate_calls(actual_caller + 1, specificNumber)
    end
  end
end

# Function that starts the program.
Proyecto1.generate_calls(0, :rand.uniform(200))
