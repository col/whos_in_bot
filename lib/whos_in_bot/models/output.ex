defmodule WhosInBot.Models.Output do
  alias WhosInBot.Models.Response

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
