defmodule CurrencyConverter.Fixer do
  @moduledoc """
  Hold the functions and logic for requesting fixer.io
  """

  alias CurrencyConverter.Fixer.Client

  @spec convert(String.t(), String.t(), float()) :: {:ok, map()} | {:error, map()}
  @doc """
  Use fixer.io for converting currencies, receives two currencies one to be converted from and other to be converted to.

  Returns a tuple with :ok and a map with the result of the opeartion.

  ## Example


      iex> CurrencyConverter.Fixer.convert("usd", "brl", 1000)
      {:ok,
        %{
           amount: 100,
           from: "USD",
           rate: 5.134855,
           result: 513.4855,
           timestamp: 1652296263,
           to: "BRL"
      }}
  """
  def convert(from, to, amount) do
    case Client.get_convert(from, to, amount) do
      {:ok, %{status: 200, body: %{"success" => true} = body}} ->
        {:ok, map_response(body)}

      {:ok, %{status: 200, body: %{"success" => false, "error" => error}}} ->
        {:error, map_error(error)}

      {:ok, %{status: 401}} ->
        {:error, :unauthorized}

      {:error, error} ->
        {:error, error}
    end
  end

  defp map_response(body) do
    %{
      from: body["query"]["from"],
      to: body["query"]["to"],
      amount: body["query"]["amount"],
      result: body["result"],
      rate: body["info"]["rate"],
      timestamp: body["info"]["timestamp"]
    }
  end

  defp map_error(error) do
    %{
      type: error["type"],
      message: error["info"]
    }
  end
end
