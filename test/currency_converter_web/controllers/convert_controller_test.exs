defmodule CurrencyConverterWeb.ConvertControllerTest do
  use CurrencyConverterWeb.ConnCase

  setup do
    bypass = Bypass.open()

    Application.put_env(
      :currency_converter,
      CurrencyConverter.Fixer.Client,
      %{base_url: "http://localhost:#{bypass.port}"}
    )

    {:ok, bypass: bypass}
  end

  describe "GET /convert" do
    test "with valid parameters should return 200 and the response JSON", %{
      conn: conn,
      bypass: bypass
    } do
      Bypass.expect_once(bypass, "GET", "/convert", fn conn ->
        response = %{
          "success" => true,
          "query" => %{
            "from" => "USD",
            "to" => "BRL",
            "amount" => 10
          },
          "info" => %{
            "timestamp" => 1_652_272_268,
            "rate" => 5.129941
          },
          "date" => "2022-05-11",
          "result" => 51.29941
        }

        conn
        |> Plug.Conn.merge_resp_headers([{"content-type", "application/json"}])
        |> Plug.Conn.resp(200, Jason.encode!(response))
      end)

      conn = get(conn, "/convert", %{"from" => "usd", "to" => "brl", "amount" => 10})

      assert %{
               "from" => "USD",
               "to" => "BRL",
               "amount" => 10,
               "result" => 51.29941,
               "rate" => 5.129941,
               "timestamp" => 1_652_272_268
             } = json_response(conn, 200)
    end

    test "with invalid parameters returns bad request and a error message", %{conn: conn} do
      conn = get(conn, "/convert", %{"from" => "usd"})

      assert response = json_response(conn, 400)
      assert response["error"] == "Invalid parameters"
    end

    test "with invalid currency returns bad request with an error message", %{
      conn: conn,
      bypass: bypass
    } do
      Bypass.expect_once(bypass, "GET", "/convert", fn conn ->
        response = %{
          "success" => false,
          "error" => %{
            "code" => 402,
            "type" => "invalid_from_currency",
            "info" => "You have entered an invalid \"from\" property. [Example: from=EUR]"
          }
        }

        conn
        |> Plug.Conn.merge_resp_headers([{"content-type", "application/json"}])
        |> Plug.Conn.resp(200, Jason.encode!(response))
      end)

      conn = get(conn, "/convert", %{"from" => "INVALID", "to" => "brl", "amount" => 1000})

      assert response = json_response(conn, 400)
      assert response["type"] == "invalid_from_currency"

      assert response["message"] ==
               "You have entered an invalid \"from\" property. [Example: from=EUR]"
    end
  end
end
