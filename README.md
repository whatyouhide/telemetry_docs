# TelemetryDocs

Generate Markdown documentation for your [`:telemetry`](https://github.com/beam-telemetry/telemetry) events.

Define your events as structured data and render them into a Markdown page suitable for use as an [ExDoc extra](https://hexdocs.pm/ex_doc/Mix.Tasks.Docs.html#module-configuration).

## Usage

Describe your telemetry events as a list of sections:

```elixir
sections = [
  %{
    title: "Query Events",
    doc: "Spans emitted when executing queries.",
    events: [
      "[:my_app, :query, :start]": %{
        doc: "Emitted before a query is executed.",
        since: "1.2.0",
        measurements: [
          system_time: [type: "t:integer/0", doc: "System time in native units."]
        ],
        metadata: [
          query: [type: "t:String.t/0", doc: "The query string."],
          repo: [type: "t:atom/0", doc: "The repo module."]
        ]
      },
      "[:my_app, :query, :stop]": %{
        doc: "Emitted after a query completes.",
        since: "1.2.0",
        measurements: [
          duration: [type: "t:integer/0", doc: "Duration in native time units."]
        ],
        metadata: [
          query: [type: "t:String.t/0", doc: "The query string."],
          result: [type: "t:term/0", doc: "The query result."]
        ]
      }
    ]
  }
]
```

Then render to Markdown:

```elixir
TelemetryDocs.sections_to_markdown(sections)
```

This produces:

```markdown
## Query Events

Spans emitted when executing queries.

### `[:my_app, :query, :start]`

*Available since v1.2.0*.

Emitted before a query is executed.

**Measurements**:
* `:system_time` (`t:integer/0`) - System time in native units.

**Metadata**:
* `:query` (`t:String.t/0`) - The query string.
* `:repo` (`t:atom/0`) - The repo module.

### `[:my_app, :query, :stop]`

*Available since v1.2.0*.

Emitted after a query completes.

**Measurements**:
* `:duration` (`t:integer/0`) - Duration in native time units.

**Metadata**:
* `:query` (`t:String.t/0`) - The query string.
* `:result` (`t:term/0`) - The query result.
```

## Integration with ExDoc

Generate the Markdown file before running `mix docs` and include it as an extra:

```elixir
# lib/mix/tasks/docs.ex
defmodule Mix.Tasks.MyApp.Docs do
  use Mix.Task

  @shortdoc "Generate docs with telemetry events page"
  def run(args) do
    content = TelemetryDocs.sections_to_markdown(MyApp.Telemetry.sections())
    File.write!("pages/telemetry-events.md", content)
    Mix.Task.run("docs", args)
  end
end
```

Then in your `mix.exs`:

```elixir
def project do
  [
    # ...
    docs: [
      extras: ["pages/telemetry-events.md"]
    ]
  ]
end
```

## Installation

Add `telemetry_docs` to your list of dependencies in `mix.exs`, in whatever Mix environment you're using ExDoc in:

```elixir
def deps do
  [
    {:telemetry_docs, "~> 0.1.0", only: :dev}
  ]
end
```
