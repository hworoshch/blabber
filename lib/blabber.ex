defmodule Blabber do
  @moduledoc """
  Blabber entrypoint combines text generation and sentiment analysis
  to provide an interactive chat with response scoring.
  """

  alias Blabber.ChatCompletion

  @doc """
  Generates a response for the given prompt and analyzes its sentiment.

  Accepts optional :text_engine and :sentiment_engine.
  """
  def chat(prompt, opts \\ []) when is_binary(prompt) do
    {text_engine, opts} = Keyword.pop(opts, :text_engine, Blabber.FlanT5)
    {sentiment_engine, opts} = Keyword.pop(opts, :sentiment_engine, Blabber.Distilbert)

    text_opts = Keyword.put(opts, :engine, text_engine)
    text_raw = ChatCompletion.call(prompt, text_opts)
    text_str = ChatCompletion.to_string(text_raw, text_opts)

    sentiment_opts = Keyword.put(opts, :engine, sentiment_engine)
    sentiment_raw = ChatCompletion.call(text_str, sentiment_opts)
    sentiment_str = ChatCompletion.to_string(sentiment_raw, sentiment_opts)

    "Answer: #{text_str}\n#{sentiment_str}"
  end
end
