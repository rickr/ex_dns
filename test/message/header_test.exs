defmodule ExDns.Message.Header.Test do
  use ExUnit.Case, async: true

  test 'returns the correct id' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<226, 84>> == parsed_message[:header][:id])
  end

  test 'returns the correct qr' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<0::size(1)>> == parsed_message[:header][:qr])
  end

  test 'returns the correct opcode' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<0::size(4)>> == parsed_message[:header][:opcode])
  end

  test 'returns the correct aa' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<0::size(1)>> == parsed_message[:header][:aa])
  end

  test 'returns the correct tc' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<0::size(1)>> == parsed_message[:header][:tc])
  end

  test 'returns the correct rd' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<1::size(1)>> == parsed_message[:header][:rd])
  end

  test 'returns the correct ra' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<0::size(1)>> == parsed_message[:header][:ra])
  end

  test 'returns the correct z' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<0::size(3)>> == parsed_message[:header][:z])
  end

  test 'returns the correct rcode' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(<<0::size(4)>> == parsed_message[:header][:rcode])
  end

  test 'returns the correct qdcount' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(1 == parsed_message[:header][:qdcount])
  end

  test 'returns the correct ancount' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(0 == parsed_message[:header][:ancount])
  end

  test 'returns the correct nscount' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(0 == parsed_message[:header][:nscount])
  end

  test 'returns the correct arcount' do
    parsed_message = MockRequest.tcp |> ExDns.Message.Header.parse
    assert(0 == parsed_message[:header][:arcount])
  end
end
