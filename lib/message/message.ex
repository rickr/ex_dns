defmodule ExDns.Message do
  def new do
    message_struct(nil)
  end

  def new(data) do
    message_struct(data)
  end

  def parse(message) do
    message
      |> ExDns.Message.Header.parse
      |> ExDns.Message.Question.parse
      |> ExDns.Message.ResourceRecord.parse
  end

  defp message_struct(initial_data) do
    [ header: [], question: [], resource_records: [], remaining_data: initial_data, original_data: initial_data]
  end
end
