defmodule WhosInBot.Models.RollCall do
  alias WhosInBot.Models.{RollCall, Response}

  defstruct [chat_id: nil, title: "", quiet: false, responses: []]

  def new(chat_id, title) do
    %RollCall{chat_id: chat_id, title: title, quiet: false, responses: []}
  end

  def add_response(roll_call, response) do
    responses = Enum.reject(roll_call.responses, fn(r) -> r.user_id == response.user_id end)
    %{roll_call | responses: [response|responses]}
  end

  def set_in(roll_call, user, reason \\ "") do
    add_response(roll_call, Response.new(user.id, user.first_name, "in", reason))
  end

  def set_out(roll_call, user, reason \\ "") do
    add_response(roll_call, Response.new(user.id, user.first_name, "out", reason))
  end

  def has_title?(roll_call) do
    String.length(roll_call.title) > 0
  end

  def responses(roll_call, status) do
    Enum.filter(roll_call.responses, fn(r) -> r.status == status end)
  end

  # TODO: REFACTOR!
  def whos_in(roll_call) do
    output = []

    if has_title?(roll_call) do
      output = [roll_call.title]
    end

    output = responses(roll_call, "in")
      |> Stream.with_index
      |> Enum.reduce(output, fn({response, index}, acc) ->
           [Response.whos_in_line(response, index)|acc]
         end)

    unless Enum.empty?(responses(roll_call, "out")) do
      output = ["Out"|output]
    end

    output = responses(roll_call, "out")
     |> Stream.with_index
     |> Enum.reduce(output, fn({response, index}, acc) ->
          [Response.whos_in_line(response, index)|acc]
        end)

    output = Enum.reverse(output)
    output = output ++ [""]
    Enum.join(output, "\n")
  end

end
