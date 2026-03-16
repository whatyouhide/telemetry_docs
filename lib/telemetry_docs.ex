defmodule TelemetryDocs do
  @field_schema [
    type: [type: :string, required: true, doc: "The typespec for the field."],
    doc: [type: :string, required: true, doc: "A description of the field."]
  ]

  @event_schema [
    doc: [type: :string, doc: "Documentation for this event."],
    since: [
      type: :string,
      doc: """
      The version of the application this event was added on. Leave empty
      if you want to omit this.
      """
    ],
    measurements: [
      type: :keyword_list,
      keys: [*: [type: :non_empty_keyword_list, keys: @field_schema]],
      type_spec: quote(do: [unquote(NimbleOptions.option_typespec(@field_schema))]),
      default: [],
      doc: "The measurements emitted with this event."
    ],
    metadata: [
      type: :keyword_list,
      keys: [*: [type: :non_empty_keyword_list, keys: @field_schema]],
      type_spec: quote(do: [unquote(NimbleOptions.option_typespec(@field_schema))]),
      default: [],
      doc: "The metadata emitted with this event."
    ]
  ]

  @section_schema [
    title: [
      type: :string,
      doc: """
      The section heading. If empty, the section will be rendered without a heading.
      """
    ],
    doc: [
      type: :string,
      doc: "Optional documentation for this section."
    ],
    events: [
      type: :non_empty_keyword_list,
      keys: [*: [type: :non_empty_keyword_list, keys: @event_schema]],
      type_spec: quote(do: [unquote(NimbleOptions.option_typespec(@event_schema))]),
      required: true,
      doc: "The telemetry events in this section."
    ]
  ]

  @moduledoc """
  Generates Markdown documentation from structured telemetry event definitions.

  ## Usage

  Implement this behaviour in your application module to declare telemetry events:

      defmodule MyApp.Telemetry do
        @behaviour TelemetryDocs

        @impl true
        def telemetry_events do
          _sections = [
            [
              title: "Request Events",
              events: [
                "[:my_app, :request, :start]": [
                  doc: "Emitted when a request begins.",
                  measurements: [
                    system_time: [
                      type: "`t:integer/0`",
                      doc: "System time."
                    ]
                  ],
                  metadata: [
                    method: [
                      type: "`t:String.t/0`",
                      doc: "HTTP method."
                    ]
                  ]
                ]
              ]
            ]
          ]
        end
      end

  See `c:telemetry_events/0` for the expected structure of the telemetry event definitions.
  """

  @typedoc """
  Attributes for a section containing events.
  """
  @type section() :: [unquote(NimbleOptions.option_typespec(@section_schema))]

  @doc """
  Returns the list of telemetry event sections.

  Events are nested keyword lists and are defined as lists of sections, containing events:

  #{NimbleOptions.docs(@section_schema)}
  """
  @callback telemetry_events() :: [section(), ...]

  @doc """
  Generates a Markdown string from the telemetry events defined in the given module.

  `module` must implement the `TelemetryDocs` behaviour.
  """
  @spec to_markdown(module()) :: String.t()
  def to_markdown(module) when is_atom(module) do
    sections_to_markdown(module.telemetry_events())
  end

  # Made public for testing.
  @doc false
  @spec sections_to_markdown([keyword(), ...]) :: String.t()
  def sections_to_markdown([_ | _] = sections) do
    sections = Enum.map(sections, &NimbleOptions.validate!(&1, @section_schema))

    sections
    |> Enum.map_join("\n\n", &render_section/1)
    |> Kernel.<>("\n")
  end

  defp render_section(section) do
    events = Keyword.fetch!(section, :events)

    parts =
      case Keyword.get(section, :title) do
        nil -> []
        title -> ["## #{title}"]
      end

    parts = parts ++ List.wrap(Keyword.get(section, :doc))

    event_parts = Enum.map(events, fn {name, event} -> render_event(name, event) end)

    Enum.join(parts ++ event_parts, "\n\n")
  end

  defp render_event(name, event) do
    parts = ["### `#{name}`"]

    parts =
      case Keyword.get(event, :since) do
        nil -> parts
        version -> parts ++ ["*Available since v#{version}*."]
      end

    parts =
      case Keyword.get(event, :doc) do
        nil -> parts
        doc -> parts ++ [doc]
      end

    measurements = Keyword.get(event, :measurements, [])
    metadata = Keyword.get(event, :metadata, [])

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
