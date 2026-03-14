defmodule TelemetryDocs do
  @moduledoc """
  Generates Markdown documentation from structured telemetry event definitions.
  """

  @typedoc """
  A section represents a group of related telemetry events. It has a title,
  optional documentation, and a list of events.
  """
  @type section() :: %{
          title: String.t(),
          doc: String.t() | nil,
          events: keyword(event())
        }

  @typedoc """
  An event represents a telemetry event with documentation about the event itself and
  its measurements and metadata.
  """
  @type event() :: %{
          doc: String.t() | nil,
          since: String.t() | nil,
          measurements: keyword(field()),
          metadata: keyword(field())
        }

  @typedoc """
  A measurement or metadata field.
  """
  @type field() :: %{
          type: String.t(),
          doc: String.t()
        }

  @doc """
  Renders a list of section maps into a Markdown string.
  """
  @spec sections_to_markdown([section(), ...]) :: String.t()
  def sections_to_markdown([_ | _] = sections) do
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
    header = """
    | Name | Type | Description |
    | - | - | - |\
    """

    rows =
      Enum.map_join(fields, "\n", fn {name, opts} ->
        type = Keyword.fetch!(opts, :type)
        doc = Keyword.fetch!(opts, :doc)
        "| `:#{name}` | `#{type}` | #{doc} |"
      end)

    """
    **#{label}**:

    #{header}
    #{rows}\
    """
  end
end
