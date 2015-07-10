defmodule ExDns.Response.Codes.Ra do
  def disabled do
    << 0::1 >>
  end

  def enabled do
    << 1::1 >>
  end
end
