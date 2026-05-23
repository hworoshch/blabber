defmodule BlabberWeb.ChatLive do
  use BlabberWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, prompt: "", results: [], loading: false)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <style>
      html, body { background-color: #09090b !important; color: #f4f4f5 !important; }
    </style>

    <div class="max-w-2xl mx-auto my-16 px-6 font-mono">
      <div class="mb-8 border-b border-zinc-800 pb-4">
        <h2 class="text-lg font-bold tracking-wider text-zinc-100 uppercase">Blabber Sentiment</h2>
      </div>

      <div class="h-[450px] overflow-y-auto mb-6 space-y-4 flex flex-col-reverse scrollbar-none">
        <div>
          <%= if @loading do %>
            <p class="text-sm text-amber-400/90 italic animate-pulse mb-4">// Processing graph...</p>
          <% end %>

          <%= for item <- @results do %>
            <div class="mb-4 p-4 bg-zinc-950 border border-zinc-900 rounded-lg space-y-2">
              <div class="text-sm">
                <span class="text-zinc-500 font-bold block mb-1">INPUT:</span>
                <span class="text-zinc-300 font-sans">{item.prompt}</span>
              </div>

              <div class="flex items-center justify-between border-t border-zinc-900 pt-2.5">
                <span class={[
                  "px-2 py-0.5 rounded text-xs font-bold uppercase text-white",
                  item.label == "POSITIVE" && "bg-emerald-600",
                  item.label == "NEGATIVE" && "bg-rose-600",
                  item.label == "NEUTRAL" && "bg-zinc-700"
                ]}>
                  {item.emoji} {item.label}
                </span>
                <span class="text-xs font-bold text-zinc-400">SCORE: {item.percent}%</span>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <form
        phx-submit="submit_kino_form"
        phx-change="validate"
        class="w-full flex items-center bg-zinc-950 border border-zinc-800 rounded-lg p-1 focus-within:border-zinc-500 transition-all duration-150"
      >
        <span class="text-zinc-600 font-bold pl-3 pr-1 text-sm select-none">$&nbsp;</span>
        <input
          type="text"
          name="prompt"
          value={@prompt}
          placeholder="Execute prompt..."
          disabled={@loading}
          autocomplete="off"
          class="flex-1 min-w-0 bg-transparent text-zinc-100 placeholder:text-zinc-700 text-sm py-2 focus:outline-none disabled:text-zinc-800"
        />
        <button
          type="submit"
          disabled={@loading || String.trim(@prompt) == ""}
          class="px-4 py-2 bg-zinc-100 hover:bg-zinc-200 text-zinc-950 text-xs font-bold rounded transition-colors disabled:bg-zinc-900 disabled:text-zinc-700"
        >
          EXEC
        </button>
      </form>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"prompt" => prompt}, socket) do
    {:noreply, assign(socket, prompt: prompt)}
  end

  @impl Phoenix.LiveView
  def handle_event("submit_kino_form", %{"prompt" => %{}} = _params, socket),
    do: {:noreply, socket}

  def handle_event("submit_kino_form", %{"prompt" => prompt}, socket) do
    case String.trim(prompt) do
      "" ->
        {:noreply, socket}

      clean_prompt ->
        socket = assign(socket, loading: true, prompt: "")
        parent = self()

        Task.start(fn ->
          raw_string = Blabber.chat(clean_prompt)
          {label, percent, emoji} = parse_sentiment(raw_string)

          send(
            parent,
            {:ai_output, %{prompt: clean_prompt, label: label, percent: percent, emoji: emoji}}
          )
        end)

        {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:ai_output, payload}, socket) do
    {:noreply, assign(socket, results: [payload | socket.assigns.results], loading: false)}
  end

  defp parse_sentiment(raw_string) do
    cond do
      String.contains?(raw_string, "POSITIVE") ->
        {"POSITIVE", extract_percent(raw_string), "😊"}

      String.contains?(raw_string, "NEGATIVE") ->
        {"NEGATIVE", extract_percent(raw_string), "😡"}

      true ->
        {"NEUTRAL", extract_percent(raw_string), "😐"}
    end
  end

  defp extract_percent(string) do
    case Regex.run(~r/\(([\d\.]+)\%\)/, string) do
      [_full, val] -> val
      _ -> "0"
    end
  end
end
