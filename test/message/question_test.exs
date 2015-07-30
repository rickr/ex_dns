defmodule ExDns.Message.Question.Test do
  use ExUnit.Case, async: true

  test 'returns the correct labels' do
    parsed_message = MockRequest.question |> ExDns.Message.Question.parse
    assert(["google", "com"] == parsed_message[:question][:labels])
  end

  test 'returns the correct qtype' do
    parsed_message = MockRequest.question |> ExDns.Message.Question.parse
    assert(1 == parsed_message[:question][:qtype])
  end

  test 'returns the correct qclass' do
    parsed_message = MockRequest.question |> ExDns.Message.Question.parse
    assert(1 == parsed_message[:question][:qclass])
  end
end
