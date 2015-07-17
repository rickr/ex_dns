defmodule ExDns.Resolve do
  @root_hints_url 'http://www.internic.net/domain/named.root'

  def random(list) do
    :random.seed(:erlang.now)
    Enum.at(list, :random.uniform(length(list)) - 1)
  end

  def root_servers do
    #["198.41.0.4", "192.228.79.201"]
    ["192.228.79.201"]
    #["198.41.0.4"]
  end

  # I feel like this is named poorly in this context
  # but when being called it would look like ExDns.Resolve.labels(labels)
  # which kind of makes sense
  def labels(labels) do
    ip = labels
      |> fetch_ns_record
      |> fetch_a_record
    IO.puts "FINAL IP: #{inspect(ip)}"
    ip
  end

  def fetch_ns_record(labels) do
    List.foldr(labels, {}, fn(cur_label, ns_ip_and_label) -> ask_for_authoritative(ns_ip_and_label, cur_label) end)
  end

  def ask_for_authoritative(ns_ip_and_label, cur_label) do
    IO.puts(inspect(ns_ip_and_label))
    {ns_ip, full_label} = case ns_ip_and_label do
      {} -> {random(root_servers), ""}
      {_, _} -> {"1.2.3.4", Tuple.to_list(ns_ip_and_label) |> List.last}
    end

    # This is kind of crappy. On our initial run we pass in an empty tuple.
    # Above we match on an empty tuple and set full_label to an empty string.
    # This gives us the result of appending a "." to our initial label.
    #label = "#{cur_label}.#{full_label}"
    label = cur_label

    IO.puts("Asking #{ns_ip} for label: #{label} (NS)")
    case ExDns.Request.build(label, "ns") |> send_request(ns_ip) do
      {:ok, {_socket, message}} -> ExDns.Message.new(message) |> ExDns.Message.parse
      {:failed, {socket, _}} -> IO.puts "Failed Request"; close_socket(socket)
    end
    {ns_ip, label}
  end

  def fetch_a_record(auth_ip_and_label) do
    {auth_ip, label} = auth_ip_and_label
    IO.puts("Asking #{auth_ip} for label #{label} (A)")
    "1.2.3.4"
  end

  def send_request(request, ns_server) do
    IO.puts("TX data (#{bit_size(request)}) #{inspect(request)} to #{inspect(ns_server)}")
    {:ok, socket} = :gen_udp.open(0, [:binary, active: false])
    {:ok, dest_ip} = :inet_parse.address(String.to_char_list(ns_server))
    :gen_udp.send(socket, dest_ip, 53, request)
    case :gen_udp.recv(socket, 0, 2000) do
      {:ok, {_, _, message}} -> IO.puts("RX data #{inspect(message)}"); {:ok, {socket, message}}
      _ -> {:failed, {socket, :failed}}
    end
  end

  def close_socket(socket) do
    :gen_udp.close(socket)
  end
end
