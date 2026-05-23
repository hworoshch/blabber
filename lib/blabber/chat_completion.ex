defmodule Blabber.ChatCompletion do
  @moduledoc """
  The behaviour which defines the last mile communication to chat response provider
  """

  @doc "Callback to be implemented for actual call"
  @callback call(request :: any(), opts :: keyword()) :: term()
  @callback to_string(term()) :: String.t()

  @optional_callbacks to_string: 1

  @default_engine Blabber.Stub

  @spec call(any(), keyword()) :: term()
  def call(request, opts \\ []) do
    {engine, opts} = Keyword.pop(opts, :engine, @default_engine)
    engine.call(request, opts)
  end

  @spec to_string(term(), keyword()) :: String.t()
  def to_string(outcome, opts \\ []) do
    {engine, _opts} = Keyword.pop(opts, :engine, @default_engine)

    if function_exported?(engine, :to_string, 1) do
      engine.to_string(outcome)
    end || inspect(outcome)
  end
end
