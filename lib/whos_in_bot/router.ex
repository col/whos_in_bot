defmodule WhosInBot.Router do
  use Plug.Router
  import Atom.Chars

  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     pass:  ["application/json"],
                     json_decoder: Poison
  plug :match
  plug :dispatch

  post "/telegram/message" do
    message = to_atom(conn.params).message
    case WhosInBot.MessageHandler.handle_message(message) do
      {:ok, response} ->
        Nadia.send_message(message.chat.id, response)
        conn |> send_resp(200, "")
      _ ->
        conn |> send_resp(400, "")
    end
  end

  match _ do
    send_resp(conn, 404, "WhosInBot: 404 - Page not found")
  end

end
