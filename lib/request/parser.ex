defmodule ExDns.Request.Parser do
  @header_size 96
  @qname_length_size 8

  def parse(message) do
    message_length = bit_size(message)
    question_length = message_length - @header_size
    IO.puts "message length #{message_length}"
    IO.puts "header length #{@header_size}"
    IO.puts "question length #{question_length}"

    <<
      header :: bits-size(@header_size),
      question :: bits-size(question_length)
    >> = message

    ExDns.Header.Parser.parse(header)
      |> parse_question(question)
  end


  #############
  # private
  #############
  defp parse_question(parsed_header, question) do
    parse_question(parsed_header[:qdcount], question, [], parsed_header)
  end

  defp parse_question(qdcount, question, labels, parsed_header) when qdcount > 0 do
    case parse_qname(question, labels, bit_size(question)) do
      {:ok, data} ->
        << qtype :: integer-size(16), qclass :: integer-size(16) >> = data[:remaining_question]
        parsed_question = [labels: data[:labels], qtype: qtype, qclass: qclass]
        parse_question(qdcount - 1, question, parsed_question, parsed_header)
    end
  end

  defp parse_question(qdcount, _question, parsed_question, parsed_header) when qdcount == 0 do
    [header: parsed_header, question: parsed_question]
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
