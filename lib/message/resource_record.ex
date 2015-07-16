defmodule ExDns.Message.ResourceRecord do
  def parse(message_struct) do
    case bit_size(message_struct[:remaining_data]) do
      0 -> IO.puts "No data left"
      _ -> IO.puts "Data left to parse!"
    end
    message_struct
  end
end
