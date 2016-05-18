defmodule WhosInBot.Models.RollCall do
  alias WhosInBot.Models.{RollCall, Response}

  defstruct [chat_id: nil, title: "", quiet: false, responses: []]

  def new(chat_id, title) do
    %RollCall{chat_id: chat_id, title: title, quiet: false, responses: []}
  end

  def add_response(roll_call, user_id, name, status, reason \\ "") do
    add_response(roll_call, Response.new(user_id, name, status, reason))
  end

  def add_response(roll_call, response) do
    responses = roll_call.responses
      |> Enum.reject(fn(r) -> r.user_id == response.user_id end)
      |> Enum.reject(fn(r) -> (r.user_id == nil || response.user_id == nil) && r.name == response.name end)
    %{roll_call | responses: responses++[response]}
  end

  def set_title(roll_call, title) do
    %{roll_call | title: title}
  end

  def has_title?(roll_call) do
    String.length(roll_call.title) > 0
  end

  def responses(roll_call, status) do
    Enum.filter(roll_call.responses, fn(r) -> r.status == status end)
  end

  def whos_in(roll_call, response \\ %{})

  def whos_in(%{responses: []}, _) do
    "No responses yet. 😢"
  end

  def whos_in(roll_call = %{quiet: true}, response) do
    num_in = Enum.count(responses(roll_call, "in"))
    num_out = Enum.count(responses(roll_call, "out"))
    num_maybe = Enum.count(responses(roll_call, "maybe"))
    response_desc = case response.status do
      "in" -> "#{response.name} is in!"
      "out" -> "#{response.name} is out!"
      "maybe" -> "#{response.name} might come."
    end
    "#{response_desc}\nTotal: #{num_in} In, #{num_out} Out, #{num_maybe} Maybe\n"
  end

  defmodule Output do
    def set_title(lines, ""), do: lines
    def set_title(lines, title) do
      [title|lines]
    end

    def add_responses(lines, response, section \\ nil)
    def add_responses(lines, [], _), do: lines
    def add_responses(lines, responses, nil), do: lines ++ lines_for(responses)
    def add_responses([], responses, section), do: [section] ++ lines_for(responses)
    def add_responses(lines, responses, section), do: lines ++ ["", section] ++ lines_for(responses)

    defp lines_for(responses) do
      responses
        |> Stream.with_index
        |> Enum.map(fn({response, index}) -> Response.whos_in_line(response, index) end)
    end

    def print(lines) do
      Enum.join(lines, "\n") <> "\n"
    end
  end

  def whos_in(roll_call, _) do
    []
      |> Output.set_title(roll_call.title)
      |> Output.add_responses(responses(roll_call, "in"))
      |> Output.add_responses(responses(roll_call, "maybe"), "Maybe")
      |> Output.add_responses(responses(roll_call, "out"), "Out")
      |> Output.print
  end

end
