defmodule ExDns.Resolve do
  @root_hints_url 'http://www.internic.net/domain/named.root'

  def root_servers do
    ["198.41.0.4", "192.228.79.201"]
  end

  # I feel like this is named poorly in this context
  # but when being called it would look like ExDns.Resolve.labels(labels)
  # which kind of makes sense
  def labels(labels) do
    ip = labels |> fetch_ns_record |> fetch_a_record
    IO.puts "FINAL IP: #{inspect(ip)}"
    ip
  end

  def fetch_ns_record(labels) do
    IO.puts(inspect(labels))
    ns_ip = List.foldr(labels, nil, fn(label, auth_server) -> ask_for_authoritative(auth_server, label) end)
    [label: List.first(labels), ns_ip: ns_ip]
  end

  def fetch_a_record(auth_server) do
    IO.puts("Asking #{auth_server[:ns_ip]} for label #{auth_server[:label]} (A)")
    "1.2.3.4"
  end

  def ask_for_authoritative(auth_server, label) do
    ns_server = case auth_server do
      nil -> random(root_servers)
      _ -> "1.2.3.4"
    end

    IO.puts("Asking #{ns_server} for label: #{label} (NS)")
    send_request(ns_server, label) |> close_socket
  end

  def send_request(ns_server, lable) do
    {:ok, socket} = :gen_udp.open(0, [:binary])
    #:gen_udp.send(socket, ns_server, 53, 0)
    socket
  end

  def close_socket(socket) do
    :gen_udp.close(socket)
  end


  def random(list) do
    :random.seed(:erlang.now)
    Enum.at(list, :random.uniform(length(list)) - 1)
  end
end
