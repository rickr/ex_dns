defmodule ExDns.Response.Codes.Aa do
  def not_authoritative do
    << 0::1 >>
  end

  def authoritative do
    << 1::1 >>
  end
end
