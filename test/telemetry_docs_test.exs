defmodule TelemetryDocsTest do
  use ExUnit.Case, async: true

  describe "sections_to_markdown/1" do
    test "renders a full data structure" do
      sections = [
        %{
          title: "Connection Events",
          doc: "Events related to connections.",
          events: [
            "[:app, :connected]": %{
              doc: "Executed when a connection is established.",
              since: "0.1.0",
              measurements: [
                duration: [type: "t:integer/0", doc: "Time in native units."]
              ],
              metadata: [
                connection: [type: "t:pid/0", doc: "The connection PID."],
                host: [type: "t:String.t/0", doc: "The host address."]
              ]
            }
          ]
        }
      ]

      result = TelemetryDocs.sections_to_markdown(sections)

      assert result == """
             ## Connection Events

             Events related to connections.

             ### `[:app, :connected]`

             *Available since v0.1.0*.

             Executed when a connection is established.

             **Measurements**:

             | Name | Type | Description |
             | - | - | - |
             | `:duration` | `t:integer/0` | Time in native units. |

             **Metadata**:

             | Name | Type | Description |
             | - | - | - |
             | `:connection` | `t:pid/0` | The connection PID. |
             | `:host` | `t:String.t/0` | The host address. |
             """
    end

    test "renders multiple sections and events" do
      sections = [
        %{
          title: "Section A",
          events: [
            "[:app, :start]": %{
              doc: "Start event.",
              measurements: [],
              metadata: []
            }
          ]
        },
        %{
          title: "Section B",
          events: [
            "[:app, :stop]": %{
              doc: "Stop event.",
              measurements: [
                duration: [type: "t:integer/0", doc: "Duration."]
              ],
              metadata: []
            }
          ]
        }
      ]

      result = TelemetryDocs.sections_to_markdown(sections)

      assert result =~ "## Section A"
      assert result =~ "## Section B"
      assert result =~ "### `[:app, :start]`"
      assert result =~ "### `[:app, :stop]`"
    end

    test "omits since when not present" do
      sections = [
        %{
          title: "Events",
          events: [
            "[:app, :event]": %{
              doc: "An event.",
              measurements: [],
              metadata: []
            }
          ]
        }
      ]

      result = TelemetryDocs.sections_to_markdown(sections)

      refute result =~ "Available since"
      assert result =~ "An event."
    end

    test "omits section doc when not present" do
      sections = [
        %{
          title: "Events",
          events: [
            "[:app, :event]": %{
              doc: "An event.",
              measurements: [],
              metadata: []
            }
          ]
        }
      ]

      result = TelemetryDocs.sections_to_markdown(sections)

      # Section heading followed directly by event heading (no doc paragraph between)
      assert result =~ "## Events\n\n### `[:app, :event]`"
    end

    test "renders none for empty measurements and metadata" do
      sections = [
        %{
          title: "Events",
          events: [
            "[:app, :event]": %{
              doc: "An event.",
              measurements: [],
              metadata: []
            }
          ]
        }
      ]

      result = TelemetryDocs.sections_to_markdown(sections)

      assert result =~ "**Measurements**: *none*"
      assert result =~ "**Metadata**: *none*"
    end

    test "renders empty sections" do
      sections = [
        %{
          title: "Empty Section",
          events: []
        }
      ]

      result = TelemetryDocs.sections_to_markdown(sections)

      assert result == "## Empty Section\n"
    end

    test "omits event doc when not present" do
      sections = [
        %{
          title: "Events",
          events: [
            "[:app, :event]": %{
              since: "1.0.0",
              measurements: [],
              metadata: []
            }
          ]
        }
      ]

      result = TelemetryDocs.sections_to_markdown(sections)

      assert result =~ "*Available since v1.0.0*."
      refute result =~ "\n\n\n"
    end
  end
end
