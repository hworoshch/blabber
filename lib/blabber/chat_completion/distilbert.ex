defmodule Blabber.Distilbert do
  @moduledoc "Handles text sentiment classification using a Hugging Face model."

  use GenServer
  @behaviour Blabber.ChatCompletion

  @default_model {:hf, "lxyuan/distilbert-base-multilingual-cased-sentiments-student"}

  def start_link(opts \\ []) do
    {name, opts} = opts |> Keyword.put_new(:name, __MODULE__) |> Keyword.pop!(:name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl GenServer
  def init(opts) do
    {model_base, _opts} = Keyword.pop(opts, :model, @default_model)

    {:ok, model} = Bumblebee.load_model(model_base)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(model_base)

    serving =
      Bumblebee.Text.text_classification(model, tokenizer,
        top_k: 1,
        defn_options: [compiler: EXLA]
      )

    {:ok, %{serving: serving}}
  end

  @impl GenServer
  def handle_call({:serve, prompt}, _from, %{serving: serving} = state) do
    {:reply, Nx.Serving.run(serving, prompt), state}
  end

  @impl Blabber.ChatCompletion
  def call(request, opts) do
    {callback, opts} = Keyword.pop(opts, :callback)
    {name, _opts} = Keyword.pop(opts, :name, __MODULE__)

    response = GenServer.call(name, {:serve, request}, :infinity)

    case callback do
      f when is_function(f, 1) -> f.(response)
      _ -> response
    end
  end

  @impl Blabber.ChatCompletion
  def to_string(%{predictions: [%{label: label, score: score}]}) do
    "[Sentiment: #{String.upcase(label)} (#{Float.round(score * 100, 1)}%)]"
  end

  @impl Blabber.ChatCompletion
  def to_string(other), do: inspect(other)
end
