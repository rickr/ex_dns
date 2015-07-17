defmodule ExDns.Message.ResourceRecord do
  #                                 1  1  1  1  1  1
  #   0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |                                               |
  # /                                               /
  # /                      NAME                     /
  # |                                               |
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |                      TYPE                     |
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |                     CLASS                     |
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |                      TTL                      |
  # |                                               |
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # |                   RDLENGTH                    |
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
  # /                     RDATA                     /
  # /                                               /
  # +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

  def new do
    [name: [], type: nil, class: nil, ttl: nil, rdlength: nil, rdata: nil]
  end

  # Could also check the counts in the header?
  def parse(message_struct) do
    resource_records = case bit_size(message_struct[:remaining_data]) do
      0 -> IO.puts "No data left"; message_struct
      _ -> ExDns.Message.ResourceRecord.new |> parse_name(message_struct)
    end
  end

  #################
  # private
  #################
  defp parse_name(resource_records, message_struct) do
    case get_name_bits(message_struct[:remaining_data]) do
      {:ok, name_label_bits} ->
        IO.puts "EXTRACTING NAME"
        {label, remaining_data} = extract_name(message_struct[:remaining_data], name_label_bits)
        IO.puts "LABEL: #{inspect(label)}"
        exit(1)
        Keyword.put(message_struct, :remaining_data, remaining_data)
        parse_name(resource_records, message_struct)
      {:pointer, offset, remaining_data} -> IO.puts "POINTER!"; deref_pointer(offset, message_struct)
      {:end_of_name, remaining_data} ->
        IO.puts "END OF NAME"
        parse_type(remaining_data, resource_records)
    end
  end

  defp extract_name(data, name_size) do
    <<
      _ :: integer-size(8),
      label :: bitstring-size(name_size),
      remaining_data :: binary
    >> = data
    IO.puts("LABEL: #{label}")
    {label, remaining_data}
  end

  defp parse_type(resource_records, message_struct) do
    IO.puts "Parsing TYPE"
    message_struct
  end


  defp get_name_bits(message) do
    << name_length_octets :: integer-size(8), remaining_data :: bitstring >> = message
    case name_length_octets do
      0 -> {:end_of_name, remaining_data}
      0b11000000 -> 
        offset = get_pointer_offset(remaining_data)
        {:pointer, offset, remaining_data}
      _ -> {:ok, name_length_octets * 8}
    end
  end

  defp get_pointer_offset(data) do
    IO.puts "DATA: #{inspect(data)}"
    << _ptr_designator :: bits-size(2), offset :: integer-size(14), _ :: bitstring >> = data
    IO.puts("offset: #{offset }")
    offset
  end

  defp deref_pointer(offset, message_struct) do
    IO.puts("Offset: #{inspect(offset)}")
    offset = 96
    << _::bits-size(offset), length :: integer-size(8), remaining_data :: bitstring >> = message_struct[:original_data]
    IO.puts("length: #{length}")
    << _offset::bits-size(offset), _length_octets :: bytes-size(1), label:: bytes-size(length), remaining_data :: bitstring >> = message_struct[:original_data]
    IO.puts("LABLE MFER: #{label}")
    message_struct
  end
end
