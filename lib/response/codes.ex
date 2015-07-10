defmodule ExDns.Response.Codes do
  defmacro __using__(_opts) do
    quote do
      import ExDns.Response.Codes.Qr
      import ExDns.Response.Codes.Rcode
      import ExDns.Response.Codes.Ra
      import ExDns.Response.Codes.Z
    end
  end
end
