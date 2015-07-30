defmodule MockRequest do
  # [
  #   header:
  #     [
  #      id: <<220, 127>>,
  #      qr: <<0::size(1)>>,
  #      opcode: <<0::size(4)>>,
  #      aa: <<0::size(1)>>,
  #      tc: <<0::size(1)>>,
  #      rd: <<1::size(1)>>,
  #      ra: <<0::size(1)>>,
  #      z: <<0::size(3)>>,
  #      rcode: <<0::size(4)>>,
  #      qdcount: 1,
  #      ancount: 0,
  #      nscount: 0,
  #      arcount: 0
  #    ],
  #    remaining_data: <<6, 103, 111, 111, 103, 108, 101, 3, 99, 111, 109, 0, 0, 1, 0, 1>>, 
  #    question: [], 
  #    resource_records: [], 
  #    original_data: <<220, 127, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 6, 103, 111, 111, 103, 108, 101, 3, 99, 111, 109, 0, 0, 1, 0, 1>>
  # ]

  # Entire TCP request for google.com
  def tcp do
    [remaining_data: <<226, 84, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 6, 103, 111, 111, 103, 108, 101, 3, 99, 111, 109, 0, 0, 1, 0, 1>>]
  end

  def question do
    [header: [qdcount: 1], remaining_data: <<6, 103, 111, 111, 103, 108, 101, 3, 99, 111, 109, 0, 0, 1, 0, 1>>]
  end
end

ExUnit.start()
