defmodule ExDns.Response.Codes.Qr do
  def query do
    << 0::1 >>
  end

  def response do
    << 1::1 >>
  end
end
