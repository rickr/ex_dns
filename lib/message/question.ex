defmodule ExDns.Message.Question do
  def parse(message_struct) do
    IO.puts "Parsing question: #{inspect(message_struct[:remaining_data])}"
    ExDns.Message.Question.parse(message_struct[:header][:qdcount], message_struct[:remaining_data], [], message_struct)
  end

  def parse(qdcount, remaining_data, labels, message_struct) when qdcount > 0 do
    case ExDns.Message.QName.parse(remaining_data, labels, qdcount) do
      {:ok, data} ->
        << qtype :: integer-size(16), qclass :: integer-size(16), remaining_data :: bitstring >> = data[:remaining_data]
        parsed_question = [labels: data[:labels], qtype: qtype, qclass: qclass]
        ExDns.Message.Question.parse(qdcount - 1, remaining_data, parsed_question, message_struct)
    end
  end

  def parse(qdcount, remaining_data, parsed_question, message_struct) when qdcount == 0 do
    IO.puts(inspect(parsed_question))
    outbound_message_struct = Keyword.put(message_struct, :remaining_data, remaining_data)
    Keyword.put(outbound_message_struct, :question, parsed_question)
  end
end
