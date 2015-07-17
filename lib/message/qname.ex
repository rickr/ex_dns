defmodule ExDns.Message.QName do
  # TODO: Poorly named
  # Size (in bits) of the length of the label
  @qname_length_size 8

  #                                 1  1  1  1  1  1
  #   0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |                                               |
  # /                     QNAME                     /
  # /                                               /
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |                     QTYPE                     |
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |                     QCLASS                    |
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # QNAME: a domain name represented as a sequence of labels,
  #        where each label consists of a length octet followed
  #        by that number of octets.


  def parse(question, labels, qdcount) when qdcount > 0 do
    case get_qname_label_bits(question) do
      {:ok, qname_label_bits} ->
        <<
          _ :: integer-size(@qname_length_size),
          label :: bitstring-size(qname_label_bits),
          remaining_question :: binary
        >> = question
        IO.puts label
        labels = List.insert_at(labels, -1, label)
        ExDns.Message.QName.parse(remaining_question, labels, qdcount)
      {:end_of_qname, remaining_question} -> ExDns.Message.QName.parse(remaining_question, labels, qdcount - 1)
    end
  end

  def parse(remaining_data, labels, qdcount) when qdcount == 0 do
    {:ok, [labels: labels, remaining_data: remaining_data]}
  end

  #################
  # private
  #################
  defp get_qname_label_bits(question) do
    << qname_length_octets :: integer-size(@qname_length_size), rest_of_question :: bitstring >> = question
    case qname_length_octets do
      0 -> {:end_of_qname, rest_of_question}
      _ -> {:ok, qname_length_octets * 8}
    end
  end
end
