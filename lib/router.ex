defmodule Router do
  use Plug.Router
  import Atom.Chars

  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     pass:  ["application/json"],
                     json_decoder: Poison
  plug :match
  plug :dispatch

  post "/telegram/message" do
    # message = to_atom(%{}).message
    # if {:ok, response} = Telegram.MessageHandler.handle_message(message) do
    #    Nadia.send_message(message.chat.id, response)
    # end
    conn |> put_resp_content_type("application/json") |> send_resp(200, "")
  end

  match _ do
    send_resp(conn, 404, "WhosInBot: 404 - Page not found")
  end

end
