defmodule Blabber.Stub do
  @moduledoc """
  Just a stub
  """

  @behaviour Blabber.ChatCompletion

  @type chat_message :: %{role: String.t(), content: String.t()}
  @type stub_request :: %{model: String.t(), messages: [chat_message()]}

  @impl Blabber.ChatCompletion
  @doc "stub request"
  @spec call(String.t() | map(), keyword()) :: String.t()
  def call(request, opts) when is_binary(request) do
    call(%{model: "gpt-5.4-mini", messages: [%{role: "user", content: request}]}, opts)
  end

  def call(%{} = request, _opts) do
    "Stubbed response for: " <> inspect(request)
  end

  @impl Blabber.ChatCompletion
  @spec to_string(any()) :: String.t()
  def to_string(outcome) when is_binary(outcome), do: outcome

  def to_string(other), do: inspect(other)
end
