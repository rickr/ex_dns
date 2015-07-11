defmodule ExDns.Response do
  use ExDns.Response.Codes
  require ExDns.Response.Values

  def for(socket, parsed_message) do
    labels = parsed_message[:question][:labels]

    # Iterate through labels
    # Check if label is in cache
    # If move on to next label
    # If nothing in cache, start at root, ask for labels in reverse
    IO.puts(inspect(labels))
    ExDns.Resolve.labels(labels)
    ExDns.Header.build(parsed_message[:header][:id], parsed_message[:header][:qdcount]) |> send_response(socket)
  end

  def send_response(response, socket) do
    msg_size = byte_size(response)
    response = << msg_size :: 16 >> <> response
    IO.puts("TX data (#{msg_size}): #{inspect(response)}")
    :gen_tcp.send(socket, response)
  end
end
