defmodule ExDns.Response.Codes.Rcode do
  # 0 - No error condition
  # 1 - Format error
  # 2 - Server failure
  # 3 - Name Error
  # 4 - Not Implemented
  # 5 - Refused
  def no_error do
    << 0::4 >>
  end

  def format_error do
    << 1::4 >>
  end

  def server_failure do
    << 2::4 >>
  end

  def name_error do
    << 3::4 >>
  end

  def not_implemented do
    << 4::4 >>
  end

  def refused do
    << 5::5 >>
  end
end
