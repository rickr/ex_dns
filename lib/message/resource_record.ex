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
    new(nil, nil)
  end

  def new(initial_data, original_data) do
    [
      label: [],
      type: nil,
      class: nil,
      ttl: nil,
      rdlength: nil,
      rdata: nil,
      remaining_data: initial_data,
      original_data: original_data]
  end

  # Could also check the counts in the header?
  def parse(message_struct) do
    case bit_size(message_struct[:remaining_data]) do
      0 -> IO.puts "No data left"; message_struct
      _ ->
        ExDns.Message.ResourceRecord.new(message_struct[:remaining_data], message_struct[:original_data])
          |> parse_name
          |> parse_type
          |> parse_class
          |> parse_ttl
          |> parse_rdlength
          |> parse_rdata
    end
  end

  #################
  # private
  #################
  defp parse_name(resource_record) do
    case get_name_bits(resource_record[:remaining_data]) do
      {:ok, name_label_bits} ->
        {label, remaining_data} = extract_name(resource_record[:remaining_data], name_label_bits)
        Keyword.put(resource_record, :label, label)
        Keyword.put(resource_record, :remaining_data, remaining_data)
      {:pointer, offset, _remaining_data} ->
        {label, remaining_data} = deref_pointer(offset, resource_record)
        resource_record = Keyword.put(resource_record, :label, label)
        resource_record = Keyword.put(resource_record, :remaining_data, remaining_data)
        resource_record
      {:end_of_name, remaining_data} ->
        resource_record = Keyword.put(resource_record, :remaining_data, remaining_data)
        parse_type(resource_record)
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

  defp parse_type(resource_record) do
    << type::integer-size(16), remaining_data::bitstring >> = resource_record[:remaining_data]
    IO.puts("Type: #{type}")
    resource_record = Keyword.put(resource_record, :type, type)
    Keyword.put(resource_record, :remaining_data, remaining_data)
  end

  defp parse_class(resource_record) do
    << class::integer-size(16), remaining_data::bitstring >> = resource_record[:remaining_data]
    IO.puts(class)
    resource_record = Keyword.put(resource_record, :class, class)
    resource_record = Keyword.put(resource_record, :remaining_data, remaining_data)
    resource_record
  end

  defp parse_ttl(resource_record) do
    << ttl::unsigned-integer-size(32), remaining_data::bitstring >> = resource_record[:remaining_data]
    IO.puts "TTL: #{ttl}"
    resource_record = Keyword.put(resource_record, :ttl, ttl)
    resource_record = Keyword.put(resource_record, :remaining_data, remaining_data)
    resource_record
  end

  defp parse_rdlength(resource_record) do
    << rdlength::unsigned-integer-size(16), remaining_data::bitstring >> = resource_record[:remaining_data]
    IO.puts "rdlength: #{rdlength}"
    resource_record = Keyword.put(resource_record, :rdlength, rdlength)
    resource_record = Keyword.put(resource_record, :remaining_data, remaining_data)
    resource_record
  end

  defp parse_rdata(resource_record) do
    rdlength = (resource_record[:rdlength] * 8)
    IO.puts("LENGTH: #{rdlength}")
    << rdata::bitstring-size(rdlength), remaining_data::bitstring >> = resource_record[:remaining_data]
    IO.puts("RDATA: '#{rdata}'")
    {label, remaining_data} = extract_name(resource_record[:remaining_data], rdlength)
    IO.puts("RDATA LABEL: '#{inspect(label)}'")
    resource_record = Keyword.put(resource_record, :rdata, rdata)
    resource_record = Keyword.put(resource_record, :remaining_data, remaining_data)
    resource_record
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
    << offset :: integer-size(14), _ :: bitstring >> = data
    offset
  end

  defp deref_pointer(offset, resource_record) do
    << _::bits-size(offset), length::integer-size(8), _remaining_data::bitstring >> = resource_record[:original_data]
    << _offset::bits-size(offset), _length_octets::bytes-size(1), label::bytes-size(length), _::bitstring >> = resource_record[:original_data]
    << _::bits-size(16), remaining_data::bitstring >> = resource_record[:remaining_data]
    {label, remaining_data}
  end
end
