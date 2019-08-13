defmodule WhosInBot.Router do
  use Plug.Router
  import Atom.Chars
  alias WhosInBot.{Repo, MessageHandler, Models}
  require Logger

  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     pass:  ["application/json"],
                     json_decoder: Jason
  plug :match
  plug :dispatch

  get "/" do
    conn |> send_resp(200, "WhosInBot")
  end

  get "/stats" do
    conn |> send_resp(200, """
    RollCalls: #{Repo.aggregate(Models.RollCall, :count, :id)}
    RollCallResponses: #{Repo.aggregate(Models.RollCallResponse, :count, :id)}
    """)
  end

  post "/telegram/message" do
    message = Map.get(to_atom(conn.params), :message, %{})
    case MessageHandler.handle_message(message) do
      {:ok, response} ->
        send_chat_response(message, response)
      _ -> nil
    end
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "WhosInBot: 404 - Page not found")
  end

  defp send_chat_response(%{ chat: %{ id: chat_id } }, response) when response != nil do
    Nadia.send_message(chat_id, response)
  end
  defp send_chat_response(_, _), do: nil

end
