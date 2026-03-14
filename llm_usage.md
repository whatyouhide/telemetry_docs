# How to Use `TelemetryDocs`

  1. Find all the places in this codebase where telemetry events are emitted. This will typically look like `:telemetry.execute/3` or `:telemetry.span/3` calls, but could also include any wrapper functions around that.
  2. For each event, extract the following information:
     * The event name (a list of atoms).
     * The measurements emitted with the event (a map of atom keys to measurement values).
     * The metadata emitted with the event (a map of atom keys to metadata values).
  3. Now, organize these events into sections and document them, their measurements, and their metadata. Do this according to the types described below.
  4. Write the events in a `pages/telemetry_events.exs` file as a **list** of sections. That file is an Elixir file, so feel free to refactor common measurements/metadata into variables or helper functions and things like that.
    
```elixir
@type section() :: %{
        title: String.t(),
        doc: String.t() | nil,
        events: keyword(event())
      }

@type event() :: %{
        doc: String.t() | nil,
        since: String.t() | nil,
        measurements: keyword(field()),
        metadata: keyword(field())
      }
      
@type field() :: %{
        type: String.t(),
        doc: String.t()
      }
```

Here's an example:

```elixir
[
  %{
    title: "Query Events",
    doc: "Spans emitted when executing queries.",
    events: [
      "[:my_app, :query, :start]": %{
        doc: "Emitted before a query is executed.",
        since: "v1.2.0",
        measurements: [
          system_time: %{
            type: "`integer()`",
            doc: "System time in native units."
          }
        ],
        metadata: [
          query: %{
            type: "`String.t()`",
            doc: "The query string."
          },
          repo: %{
            type: "`atom()`",
            doc: "The repo module."
          }
        ]
      },
      "[:my_app, :query, :stop]": %{
        doc: "Emitted after a query completes.",
        since: "v1.2.0",
        measurements: [
          duration: %{
            type: "`integer()`",
            doc: "Duration in native time units."
          }
        ],
        metadata: [
          query: %{
            type: "`String.t()`",
            doc: "The query string."
          },
          result: %{
            type: "`term()`",
            doc: "The query result."
          }
        ]
      }
    ]
  }
]
```

Verify that this is compatible with `TelemetryDocs` by running:

```elixir
mix run -e '"pages/telemetry_docs.exs" |> Code.eval_file() |> elem(0) |> TelemetryDocs.sections_to_markdown() |> IO.puts()'
```
