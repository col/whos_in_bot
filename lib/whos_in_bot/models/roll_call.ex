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
    defstruct [title: [], ins: [], outs: [], maybes: []]

    def set_title(output, ""), do: output
    def set_title(output, title) do
      %{output|title: [title]}
    end

    def add_responses(output, [], type), do: Map.put(output, type, [])
    def add_responses(output, responses, type) do
      section = case type do
        :ins -> []
        :outs -> ["Out"]
        :maybes -> ["Maybe"]
      end
      Map.put(output, type, section ++ responses_to_lines(responses))
    end

    defp responses_to_lines(responses) do
      responses
        |> Stream.with_index
        |> Enum.map(fn({response, index}) -> Response.whos_in_line(response, index) end)
    end

    def print(output) do
      lines = output.title ++ output.ins

      unless Enum.empty?(output.maybes) do
        unless Enum.empty?(lines), do: lines = lines ++ [""]
        lines = lines ++ output.maybes
      end

      unless Enum.empty?(output.outs) do
        unless Enum.empty?(lines), do: lines = lines ++ [""]
        lines = lines ++ output.outs
      end

      Enum.join(lines, "\n") <> "\n"
    end
  end

  # TODO: REFACTOR!
  def whos_in(roll_call, _) do
    %Output{}
      |> Output.set_title(roll_call.title)
      |> Output.add_responses(responses(roll_call, "in"), :ins)
      |> Output.add_responses(responses(roll_call, "maybe"), :maybes)
      |> Output.add_responses(responses(roll_call, "out"), :outs)
      |> Output.print
  end

  # def whos_in(roll_call, _) do
  #   output = []
  #
  #   if has_title?(roll_call) do
  #     output = [roll_call.title]
  #   end
  #
  #   output = responses(roll_call, "in")
  #     |> Stream.with_index
  #     |> Enum.reduce(output, fn({response, index}, acc) ->
  #          [Response.whos_in_line(response, index)|acc]
  #        end)
  #
  #    unless Enum.empty?(responses(roll_call, "maybe")) do
  #      if Enum.count(output) > 0 do
  #         output = [""|output]
  #      end
  #      output = ["Maybe"|output]
  #    end
  #
  #    output = responses(roll_call, "maybe")
  #     |> Stream.with_index
  #     |> Enum.reduce(output, fn({response, index}, acc) ->
  #          [Response.whos_in_line(response, index)|acc]
  #        end)
  #
  #   unless Enum.empty?(responses(roll_call, "out")) do
  #     if Enum.count(output) > 0 do
  #        output = [""|output]
  #     end
  #     output = ["Out"|output]
  #   end
  #
  #   output = responses(roll_call, "out")
  #    |> Stream.with_index
  #    |> Enum.reduce(output, fn({response, index}, acc) ->
  #         [Response.whos_in_line(response, index)|acc]
  #       end)
  #
  #   output = Enum.reverse(output)
  #   output = output ++ [""]
  #   Enum.join(output, "\n")
  # end

end
