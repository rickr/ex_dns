defmodule ExDns.Request.Parser do
  require ExDns.Parse

  @header_size 96

  def parse(message) do
    message_length = bit_size(message)
    question_length = message_length - @header_size
    IO.puts "message length #{message_length}"
    IO.puts "header length #{@header_size}"
    IO.puts "question length #{question_length}"

    <<
      header :: bits-size(@header_size),
      question :: bits-size(question_length)
    >> = message

    message
    |> ExDns.Header.Parser.parse
    |> ExDns.Parse.question
  end
end
