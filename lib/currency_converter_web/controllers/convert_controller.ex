defmodule CurrencyConverterWeb.ConvertController do
  use CurrencyConverterWeb, :controller

  alias CurrencyConverter.Fixer

  def index(conn, %{"from" => from, "to" => to, "amount" => amount}) do
    case Fixer.convert(from, to, amount) do
      {:ok, result} ->
        conn
        |> put_status(200)
        |> json(result)

      {:error, error} ->
        conn
        |> put_status(400)
        |> json(error)
    end
  end

  def index(conn, _) do
    conn
    |> put_status(400)
    |> json(%{
      error: "Invalid parameters"
    })
  end
end
