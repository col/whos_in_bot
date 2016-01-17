defmodule WhosInBot.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias WhosInBot.Router

  @opts Router.init([])

  @json_request "{ \"message\": { \"chat\": { \"id\": 1 }, \"text\": \"unknown_command\" } }"

  test "POST /telegram/message returns an empty response" do
    conn = conn(:post, "/telegram/message", @json_request)
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == ""
  end

  test "GET /anything_else returns a 404 error" do
    conn = conn(:post, "/anything_else")
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

end
