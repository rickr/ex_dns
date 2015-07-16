defmodule ExDns.Response.Parser do
  def parse(message) do
    message
      |> ExDns.Header.Parser.parse
      |> ExDns.Parse.question
      |> parse_rr
  end

  ###############
  # private
  ###############
  defp parse_rr(message) do
    IO.puts "RR: #{inspect(message)}"
  end
end
