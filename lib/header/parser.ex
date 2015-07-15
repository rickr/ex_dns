defmodule ExDns.Header.Parser do
  def parse(header) do
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
  end
end

