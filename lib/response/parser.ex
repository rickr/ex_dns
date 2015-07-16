defmodule ExDns.Response.Parser do
  def parse(message) do
    ExDns.Header.parse(message)
  end
end
