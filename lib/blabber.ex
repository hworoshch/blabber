defmodule Blabber do
  @moduledoc "Main entrypoint for sentiment analysis."

  alias Blabber.ChatCompletion

  @type engine :: Blabber.Distilbert | Blabber.Stub | module()
  @type option :: {:engine, engine()} | {atom(), any()}
  @type options :: [option()]

  @doc "Analyzes the sentiment of the given text."
  @spec chat(String.t(), options()) :: String.t()
  def chat(prompt, opts \\ []) when is_binary(prompt) do
    opts = Keyword.put_new(opts, :engine, Blabber.Distilbert)

    prompt
    |> ChatCompletion.call(opts)
    |> ChatCompletion.to_string(opts)
  end
end
