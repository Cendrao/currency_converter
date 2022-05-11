defmodule CurrencyConverter.Fixer.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, base_url()
  plug Tesla.Middleware.Headers, [{"apikey", apikey()}]
  plug Tesla.Middleware.JSON

  def convert(from, to, amount) do
    get("/convert?from=#{from}&to=#{to}&amount=#{amount}")
  end

  defp apikey do
    Application.fetch_env!(:currency_converter, __MODULE__)[:api_key]
  end

  defp base_url do
    Application.fetch_env!(:currency_converter, __MODULE__)[:base_url]
  end
end
