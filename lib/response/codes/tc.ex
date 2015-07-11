defmodule ExDns.Response.Codes.Tc do
  def not_truncated do
    << 0::1 >>
  end

  def truncated do
    << 1::1 >>
  end
end
