defmodule ExDns.Request do
  import ExDns.Request.Parser

  def build(label, type) do
    id = generate_id
    IO.puts "Building request for #{label} id: #{inspect(id)}"
    header = ExDns.Header.build(id, ExDns.Response.Codes.Qr.query, 1)
    question = generate_question(label)
    header <> question
  end

  def generate_id do
    :crypto.rand_bytes(2)
  end

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
  def generate_question(label) do
    label_size = byte_size(label)
    qname = << label_size :: 8 >> <> label <> << 0::8 >>
    qtype = ExDns.Response.Values.qtype("NS")
    qclass = ExDns.Response.Values.qclass("IN")
    qname <> qtype <> qclass
  end
end
