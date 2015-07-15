defmodule ExDns.Header do
  import ExDns.Header.Parser

  #  DNS Header format:
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
  def build(id \\ 0, qr \\ ExDns.Response.Codes.Qr.response, qdcount \\ 0, rd \\ 0) do
    IO.puts "Building header for id #{inspect(id)}"
    response_header = []
    response_header
      |>set_field(:id, id)
      |> set_field(:qr, qr)
      |> set_field(:opcode, ExDns.Response.Codes.Opcode.query)
      |> set_field(:aa, ExDns.Response.Codes.Aa.not_authoritative)
      |> set_field(:tc, ExDns.Response.Codes.Tc.not_truncated)
      |> set_field(:rd, ExDns.Response.Values.rd(rd))
      |> set_field(:ra, ExDns.Response.Codes.Ra.enabled)
      |> set_field(:z, ExDns.Response.Codes.Z.reserved)
      |> set_field(:rcode, ExDns.Response.Codes.Rcode.not_implemented)
      |> set_field(:qdcount, ExDns.Response.Values.qdcount(qdcount))
      |> set_field(:ancount, ExDns.Response.Values.ancount(0))
      |> set_field(:nscount, ExDns.Response.Values.nscount(0))
      |> set_field(:arcount, ExDns.Response.Values.arcount(0))
      |> pack
  end

  # Ruby makes me want to do some metaprogramming here...something like
  # set_header_<field>(header, value)...is this possible?
  def set_field(header, key, value) do
    header ++ [{key, value}]
  end

  def pack(header) do
    values = Keyword.values(header)
    bytes = :erlang.list_to_bitstring(values)
    bytes
  end
end
