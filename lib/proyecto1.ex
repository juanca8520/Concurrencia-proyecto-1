defmodule Counter do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end
end

defmodule Proyecto1 do
  children = [
    {Mutex, name: MyMutex}
  ]

  {:ok, pidMutex} = Supervisor.start_link(children, strategy: :one_for_one)

  def call(caller) do
    specificNumber = 212
    counter_id = {User, {:id, 1}}
    lock = Mutex.await(MyMutex, counter_id)
    Counter.increment()
    currentCall = Counter.value()

    if specificNumber == currentCall do
      IO.inspect("[#{caller}] You are the winner")
      Mutex.release(MyMutex, lock)
      # IO.inspect(Process.exit(pidMutex, :normal))
      # IO.inspect(pidMutex)
      # IO.inspect(counter_id)
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

  def accept_call(actual_caller, phone) do
    phone1_id = {User, {:id, 2}}
    phone2_id = {User, {:id, 3}}
    phone3_id = {User, {:id, 4}}
    phone4_id = {User, {:id, 5}}

    case phone do
      1 ->
        lock = Mutex.await(MyMutex, phone1_id)
        spawn(fn -> call(actual_caller) end)
        Mutex.release(MyMutex, lock)

      2 ->
        lock2 = Mutex.await(MyMutex, phone2_id)
        spawn(fn -> call(actual_caller) end)
        Mutex.release(MyMutex, lock2)

      3 ->
        lock3 = Mutex.await(MyMutex, phone3_id)
        spawn(fn -> call(actual_caller) end)
        Mutex.release(MyMutex, lock3)

      4 ->
        lock4 = Mutex.await(MyMutex, phone4_id)
        spawn(fn -> call(actual_caller) end)
        Mutex.release(MyMutex, lock4)
    end
  end

  def generate_calls(actual_caller) do
    # Timer
    #Process.sleep(:rand.uniform(10))
    phone_assigned = :rand.uniform(4)
    accept_call(actual_caller + 1, phone_assigned)

    if actual_caller < 2000000 do
      generate_calls(actual_caller + 1)
    end
  end
end
Proyecto1.generate_calls(0)
