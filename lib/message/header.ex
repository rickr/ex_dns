defmodule ExDns.Message.Header do
  @header_size 96

  def parse(message_struct) do
    message = message_struct[:remaining_data]
    message_length = (bit_size(message) - @header_size)

    << header::bits-size(@header_size), remaining_data::bits-size(message_length) >> = message
    message_struct = Keyword.put(message_struct, :remaining_data, remaining_data)

    <<
      id :: bits-size(16),
      qr :: bits-size(1),
      opcode :: bits-size(4),
      aa :: bits-size(1),
      tc :: bits-size(1),
      rd :: bits-size(1),
      ra :: bits-size(1),
      z :: bits-size(3),
      rcode :: bits-size(4),
      qdcount :: unsigned-integer-size(16),
      ancount :: unsigned-integer-size(16),
      nscount :: unsigned-integer-size(16),
      arcount :: unsigned-integer-size(16),
    >> = header

    Keyword.put(message_struct, :header,
      [
        id: id,
        qr: qr,
        opcode: opcode,
        aa: aa,
        tc: tc,
        rd: rd,
        ra: ra,
        z: z,
        rcode: rcode,
        qdcount: qdcount,
        ancount: ancount,
        nscount: nscount,
        arcount: arcount
      ]
    )
  end
end
