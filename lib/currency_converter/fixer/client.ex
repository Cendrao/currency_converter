defmodule CurrencyConverter.Fixer.Client do
  @moduledoc """
  Client HTTP for fixer.io
  """
  use Tesla

  plug Tesla.Middleware.BaseUrl, base_url()
  plug Tesla.Middleware.Headers, [{"apikey", apikey()}]
  plug Tesla.Middleware.JSON

  def get_convert(from, to, amount) do
    get("/convert?from=#{from}&to=#{to}&amount=#{amount}")
  end

  defp apikey do
    Application.fetch_env!(:currency_converter, __MODULE__)[:api_key]
  end

  defp base_url do
    Application.fetch_env!(:currency_converter, __MODULE__)[:base_url]
  end
end
