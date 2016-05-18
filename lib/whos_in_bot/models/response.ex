defmodule WhosInBot.Models.Response do
  alias WhosInBot.Models.Response

  defstruct [user_id: nil, name: "", status: "", reason: ""]

  def new(user_id, name, status, reason \\ "") do
    %Response{user_id: user_id, name: name, status: status, reason: reason}
  end

  def whos_in_line(response = %{status: "in", reason: ""}, index) do
    "#{index+1}. #{response.name}"
  end

  def whos_in_line(response = %{status: "in", reason: reason}, index) do
    "#{index+1}. #{response.name} #{parenthesize_reason(reason)}"
  end

  def whos_in_line(response = %{status: _, reason: ""}, _) do
    " - #{response.name}"
  end

  def whos_in_line(response = %{status: _, reason: reason}, _) do
    " - #{response.name} #{parenthesize_reason(reason)}"
  end

  defp parenthesize_reason(reason) do
    case reason do
      "("<>_ ->
          reason
      _ ->
        "(#{reason})"
    end
  end

end
