defmodule TelemetryDocs do
  @moduledoc """
  Generates Markdown documentation from structured telemetry event definitions.
  """

  @doc """
  Renders a list of section maps into a Markdown string.

  Each section map has the shape:

      %{
        title: "Section Title",
        doc: "Optional section documentation.",
        events: [
          "[:app, :event]": %{
            doc: "Event description.",
            since: "1.0.0",
            measurements: [name: [type: "t:integer/0", doc: "..."]],
            metadata: [name: [type: "t:atom/0", doc: "..."]]
          }
        ]
      }

  """
  @spec to_markdown([map()]) :: String.t()
  def to_markdown(sections) when is_list(sections) do
    sections
    |> Enum.map_join("\n\n", &render_section/1)
    |> Kernel.<>("\n")
  end

  defp render_section(%{title: title, events: events} = section) do
    parts = ["## #{title}"]

    parts =
      case Map.get(section, :doc) do
        nil -> parts
        doc -> parts ++ [doc]
      end

    event_parts = Enum.map(events, fn {name, event} -> render_event(name, event) end)

    Enum.join(parts ++ event_parts, "\n\n")
  end

  defp render_event(name, event) do
    parts = ["### `#{name}`"]

    parts =
      case Map.get(event, :since) do
        nil -> parts
        version -> parts ++ ["*Available since v#{version}*."]
      end

    parts =
      case Map.get(event, :doc) do
        nil -> parts
        doc -> parts ++ [doc]
      end

    measurements = Map.get(event, :measurements, [])
    metadata = Map.get(event, :metadata, [])

    parts = parts ++ [render_field_list("Measurements", measurements)]
    parts = parts ++ [render_field_list("Metadata", metadata)]

    Enum.join(parts, "\n\n")
  end

  defp render_field_list(label, []) do
    "**#{label}**: *none*"
  end

  defp render_field_list(label, fields) when is_list(fields) do
    items =
      Enum.map_join(fields, "\n", fn {name, opts} ->
        type = Keyword.fetch!(opts, :type)
        doc = Keyword.fetch!(opts, :doc)
        "* `:#{name}` (`#{type}`) - #{doc}"
      end)

    "**#{label}**:\n#{items}"
  end
end
