defmodule CurrencyConverter.Fixer do
  alias CurrencyConverter.Fixer.Client

  def convert(from, to, amount) do
    case Client.convert(from, to, amount) do
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
