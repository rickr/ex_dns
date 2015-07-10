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
      set_qr |>
      set_ra |>
      set_z |>
      set_rcode |>
      set_qdcount |>
      set_ancount |>
      set_nscount |>
      set_arcount |>
      pack_header
  end

  def set_qr(header) do
    Keyword.update!(header, :qr, fn(_)-> ExDns.Response.Codes.Qr.response end)
  end

  def set_ra(header) do
    Keyword.update!(header, :ra, fn(_)-> ExDns.Response.Codes.Ra.enabled end)
  end

  def set_z(header) do
    Keyword.update!(header, :z, fn(_)-> ExDns.Response.Codes.Z.reserved end)
  end

  def set_rcode(header) do
    Keyword.update!(header, :rcode, fn(_)-> ExDns.Response.Codes.Rcode.not_implemented end)
  end

  def set_qdcount(header) do
    Keyword.update!(header, :qdcount, fn(_)-> << 0::16 >> end)
  end

  def set_ancount(header) do
    Keyword.update!(header, :ancount, fn(_)-> << 0::16 >> end)
  end

  def set_nscount(header) do
    Keyword.update!(header, :nscount, fn(_)-> << 0::16 >> end)
  end

  def set_arcount(header) do
    Keyword.update!(header, :arcount, fn(_)-> << 0::16 >> end)
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
