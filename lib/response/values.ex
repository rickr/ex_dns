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

end
