defmodule ExDns.Response.Codes.Opcode do
  def query do
    << 0::4 >>
  end

  def iquery do
    << 1::4 >>
  end

  def status do
    << 2::4 >>
  end
end
