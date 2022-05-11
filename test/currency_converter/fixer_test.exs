defmodule CurrencyConverter.FixerTest do
  use ExUnit.Case

  alias CurrencyConverter.Fixer

  setup do
    bypass = Bypass.open()

    Application.put_env(
      :currency_converter,
      CurrencyConverter.Fixer.Client,
      %{base_url: "http://localhost:#{bypass.port}"}
    )

    {:ok, bypass: bypass}
  end

  describe "convert/3" do
    test "with valid parameters should return a convertion structure", %{bypass: bypass} do
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

      assert {:ok,
              %{
                from: "USD",
                to: "BRL",
                amount: 10,
                result: 51.29941,
                rate: 5.129941,
                timestamp: 1_652_272_268
              }} = Fixer.convert("usd", "brl", 10)
    end

    test "with an invalid currency should return an error", %{bypass: bypass} do
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

      assert {:error,
              %{
                type: "invalid_from_currency",
                message: "You have entered an invalid \"from\" property. [Example: from=EUR]"
              }} = Fixer.convert("INVALID", "USD", 100)
    end
  end
end
