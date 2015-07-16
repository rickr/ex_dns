defmodule ExDns.Parse do
  @qname_length_size 8

  def question(parsed_header, question) do
    ExDns.Parse.question(parsed_header[:qdcount], question, [], parsed_header)
  end

  def question(qdcount, question, labels, parsed_header) when qdcount > 0 do
    case parse_qname(question, labels, qdcount) do
      {:ok, data} ->
        << qtype :: integer-size(16), qclass :: integer-size(16), remaining_question :: bitstring >> = data[:remaining_question]
        parsed_question = [labels: data[:labels], qtype: qtype, qclass: qclass]
        ExDns.Parse.question(qdcount - 1, remaining_question, parsed_question, parsed_header)
    end
  end

  def question(qdcount, _question, parsed_question, parsed_header) when qdcount == 0 do
    [header: parsed_header, question: parsed_question]
  end


  # qname contains many labels
  defp parse_qname(question, labels, qdcount) when qdcount > 0 do
    case get_qname_label_bits(question) do
      {:ok, qname_label_bits} ->
        <<
          _ :: integer-size(@qname_length_size),
          label :: bitstring-size(qname_label_bits),
          remaining_question :: binary
        >> = question
        IO.puts inspect(label)
        IO.puts inspect(labels)
        labels = List.insert_at(labels, -1, label)
        parse_qname(remaining_question, labels, qdcount - 1)
      {:end_of_qname, remaining_question} -> parse_qname(remaining_question, labels, bit_size(remaining_question))
    end
  end

  # when the size of the question is < 32 we only have qtype and qclass remaining
  defp parse_qname(question, labels, qdcount) when qdcount == 0 do
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
