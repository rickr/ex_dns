defmodule ExDns do
  use Application
  @header_size 96
  @qname_length_size 8

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
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, active: false, reuseaddr: true])
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
        _parsed_message = parse_message(data)
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




  ###
  ### Parse
  defp parse_message(message) do
    message_length = bit_size(message)
    question_length = message_length - @header_size
    IO.puts "message length #{message_length}"
    IO.puts "header length #{@header_size}"
    IO.puts "question length #{question_length}"

    <<
      header :: bits-size(@header_size),
      question :: bits-size(question_length)
    >> = message

    parsed_header = parse_header(header)
    parsed_question = parse_question(question, parsed_header[:qdcount], [])
    IO.puts "Header: #{inspect(parsed_header)}"
    IO.puts "Question: #{inspect(parsed_question)}"
  end


  ###
  ### Parse the header
  defp parse_header(header) do
    <<
      id :: bits-size(16),
      qr :: bits-size(1),
      opcode :: bits-size(4),
      aa :: bits-size(1),
      tc :: bits-size(1),
      rd :: bits-size(1),
      ra :: bits-size(1),
      z :: bits-size(3),
      rcode :: bits-size(4),
      qdcount :: unsigned-integer-size(16),
      ancount :: unsigned-integer-size(16),
      nscount :: unsigned-integer-size(16),
      arcount :: unsigned-integer-size(16),
    >> = header

    [
      id: id,
      qr: qr,
      opcode: opcode,
      aa: aa,
      tc: tc,
      rd: rd,
      ra: ra,
      z: z,
      rcode: rcode,
      qdcount: qdcount,
      ancount: ancount,
      nscount: nscount,
      arcount: arcount
    ]
  end





  ###
  ### Parse the question section
  defp parse_question(question, qdcount, labels) when qdcount > 0 do
    case parse_qname(question, labels, bit_size(question)) do
      {:ok, data} ->
        << qtype :: integer-size(16), qclass :: integer-size(16) >> = data[:remaining_question]
        parsed_question = [labels: data[:labels], qtype: qtype, qclass: qclass]
        parse_question(question, qdcount - 1, parsed_question)
    end
  end

  defp parse_question(_question, qdcount, labels) when qdcount == 0 do
    labels
  end

  # qname contains many labels
  defp parse_qname(question, labels, question_size) when question_size > 32 do
    case get_qname_label_bits(question) do
      {:ok, qname_label_bits} ->
        <<
          _ :: integer-size(@qname_length_size),
          label :: bitstring-size(qname_label_bits),
          remaining_question :: binary
        >> = question
        labels = List.insert_at(labels, -1, label)
        parse_qname(remaining_question, labels, bit_size(remaining_question))
      {:end_of_qname, remaining_question} -> parse_qname(remaining_question, labels, bit_size(remaining_question))
    end
  end

  # when the size of the question is < 32 we only have qtype and qclass remaining
  defp parse_qname(question, labels, _question_size) do
    {:ok, [labels: labels, remaining_question: question]}
  end

  defp get_qname_label_bits(question) do
    << qname_length_octets :: integer-size(@qname_length_size), rest_of_question :: bitstring >> = question
    case qname_length_octets do
      0 -> {:end_of_qname, rest_of_question}
      _ -> {:ok, qname_length_octets * 8}
    end
  end
end
