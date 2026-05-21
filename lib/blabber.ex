defmodule Blabber do
  @moduledoc "Main entrypoint for sentiment analysis."

  alias Blabber.ChatCompletion

  @doc "Analyzes the sentiment of the given text."
  def chat(prompt, opts \\ []) when is_binary(prompt) do
    opts = Keyword.put_new(opts, :engine, Blabber.Distilbert)

    prompt
    |> ChatCompletion.call(opts)
    |> ChatCompletion.to_string(opts)
  end
end
