defmodule ExDns.Response.Values do
  # This feels like it can be done with macros?
  def two_bytes(value) do
    << value::16 >>
  end

  def qdcount(value) do
    two_bytes(value)
  end

  def ancount(value) do
    two_bytes(value)
  end

  def nscount(value) do
    two_bytes(value)
  end

  def arcount(value) do
    two_bytes(value)
  end

  def rd(value) do
    << value::1 >>
  end

  def qtype(value) do
    case value do
      "A" -> << 1::16>>
      "NS" -> << 2::16>>
      "MD" -> << 3::16>>
      "MF" -> << 4::16>>
      "CNAME" -> << 5::16>>
      "SOA" -> << 6::16>>
      "MB" -> << 7::16>>
      "MG" -> << 8::16>>
      "MR" -> << 9::16>>
      "NULL" -> << 10::16>>
      "WKS" -> << 11::16>>
      "PTR" -> << 12::16>>
      "HINFO" -> << 13::16>>
      "MINFO" -> << 14::16>>
      "MX" -> << 15::16>>
      "TXT" -> << 16::16>>
    end
  end

  def qclass(value \\ "IN") do
    case value do
      "IN" -> << 1::16 >>
      "CS" -> << 2::16 >>
      "CH" -> << 3::16 >>
      "HS" -> << 4::16 >>
    end

  end
end
