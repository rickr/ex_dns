defmodule ExDns do
  use Application
  require ExDns.Response

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: ExDns.TaskSupervisor]]),
      worker(Task, [ExDns, :accept, [4040]])
    ]

    opts = [strategy: :one_for_one, name: ExDns.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true])
    IO.puts "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  ################
  # private
  ################

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(ExDns.TaskSupervisor, fn -> serve(client) end)

    case :gen_tcp.controlling_process(client, pid) do
      {:error, _} = error -> IO.puts "Error #{inspect(error)}"
      _ ->
    end
    loop_acceptor(socket)
  end

  defp serve(socket) do
    case get_message(socket, "") do
      :ok -> IO.puts "RX'd data"
      {:ok, data} ->
        IO.puts "RX'd data #{inspect(data)}"
        parsed_message = ExDns.Message.new(data) |> ExDns.Message.parse
        ExDns.Response.for(socket, parsed_message)
      {:error, :closed} -> IO.puts "Closed"
      {:error, _} = err -> err
    end
  end

  # The first two bytes is the size of the message
  defp get_message(socket, message) do
    case :gen_tcp.recv(socket, 2) do
      {:ok, buf} -> <<msg_size::integer-size(16)>> = buf; get_message(socket, message, msg_size)
      {:error, _} = error -> IO.puts "get_message error: #{inspect(error)}"
    end
  end

  defp get_message(socket, message, msg_len) when byte_size(message) < msg_len do
    case :gen_tcp.recv(socket, msg_len) do
      {:ok, buf} -> get_message(socket, message <> buf, msg_len)
      {:error, _} = error -> IO.puts "get_message error: #{inspect(error)}"
    end
  end

  defp get_message(_, message, msg_len) when byte_size(message) == msg_len do
    {:ok, message}
  end
end
