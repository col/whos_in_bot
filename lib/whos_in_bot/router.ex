defmodule WhosInBot.Router do
  use Plug.Router
  use Honeybadger.Plug
  import Atom.Chars
  alias WhosInBot.MessageHandler

  plug Beaker.Integrations.Phoenix
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     pass:  ["application/json"],
                     json_decoder: Poison
  plug :match
  plug :dispatch

  get "/" do
    conn |> send_resp(200, "WhosInBot")
  end

  get "/stats" do
    conn |> send_resp(200, "Requests: #{Beaker.Counter.get("Phoenix:Requests")}")
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
