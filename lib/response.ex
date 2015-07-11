defmodule ExDns.Response do
  use ExDns.Response.Codes

  def for(socket, parsed_message) do
    labels = parsed_message[:question][:labels]

    header = build_header(parsed_message[:header])
    send_response(header, socket)
  end

  def send_response(response, socket) do
    msg_size = byte_size(response)
    response = << msg_size :: 16 >> <> response
    IO.puts("TX data (#{msg_size}): #{inspect(response)}")
    :gen_tcp.send(socket, response)
  end

  def check_cache_for([label|labels]) do
    IO.puts "Checking cache for label #{label}"
    check_cache_for(labels)
  end

  def check_cache_for([]) do
    IO.puts "label empty"
  end

  def get_authorotative_for(label) do
    IO.puts label
  end

  #    0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |                      ID                       |
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |                    QDCOUNT                    |
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |                    ANCOUNT                    |
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |                    NSCOUNT                    |
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |                    ARCOUNT                    |
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  def build_header(request_header) do
    response_header = request_header
    IO.puts "Building header for id #{inspect(response_header[:id])}"
    response_header = response_header |>
      set_header_field(:qr, ExDns.Response.Codes.Qr.response) |>
      set_header_field(:ra, ExDns.Response.Codes.Ra.enabled) |>
      set_header_field(:z, ExDns.Response.Codes.Z.reserved) |>
      set_header_field(:rcode, ExDns.Response.Codes.Rcode.not_implemented) |>
      set_header_field(:qdcount, << 0::16 >>) |>
      set_header_field(:ancount, << 0::16 >>) |>
      set_header_field(:nscount, << 0::16 >>) |>
      set_header_field(:arcount, << 0::16 >>) |>
      pack_header
  end

  # Ruby makes me want to do some metaprogramming here...something like
  # set_header_<field>(header, value)...is this possible?
  def set_header_field(header, key, value) do
    Keyword.update!(header, key, fn(_)-> value end)
  end

  def pack_header(header) do
    values = Keyword.values(header)
    bytes = :erlang.list_to_bitstring(values)
    IO.puts("Packing:")
    IO.puts("Header: #{inspect(header)}")
    IO.puts("bytes: #{inspect(bytes)}")
    IO.puts("Size: #{bit_size(bytes)}")
    bytes
  end
end
