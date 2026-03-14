# lex-metacognition

Second-order self-model assembly for LegionIO agents. Part of the LegionIO cognitive architecture extension ecosystem (LEX).

## What It Does

`lex-metacognition` enables an agent to build an explicit model of its own architecture, capabilities, and current cognitive state. Unlike performance monitoring, metacognition assembles a structured self-representation from live runtime introspection — the agent knowing what it is, what it can do, and what it is doing right now. Maintains a rolling snapshot history for health trending and architecture change detection.

Key capabilities:

- **Runtime introspection**: discovers loaded extensions, maps capabilities, captures tick state
- **Capability map**: groups 200+ known extensions into 8 categories (perception, cognition, memory, etc.)
- **Health trending**: cognitive health score over rolling snapshot history
- **Architecture change detection**: tracks when extensions are loaded or unloaded
- **Natural language self-description**: generates prose narrative from the self-model

## Installation

Add to your Gemfile:

```ruby
gem 'lex-metacognition'
```

Or install directly:

```
gem install lex-metacognition
```

## Usage

```ruby
require 'legion/extensions/metacognition'

client = Legion::Extensions::Metacognition::Client.new

# Build and cache a self-model
model = client.introspect(tick_results: tick_output)
# => { loaded_extensions: [...], capability_map: { cognition: [...], ... },
#      cognitive_health: 0.92, tick_mode: :full_active }

# Natural language self-description
narrative = client.self_narrative(tick_results: tick_output)
puts narrative[:prose]
# => "I am a brain_modeled cognitive_agent built on LegionIO with 24 extension slots.
#     18 of 24 extensions are active. Operating in full_active mode.
#     Running 12 phases per tick. Cognitive health: excellent (92%)."

# Explain a specific subsystem
info = client.explain_subsystem(subsystem: :memory)

# Architecture summary
client.architecture_overview

# Health trend over time
trend = client.health_trend(limit: 20)

# Detect when extensions changed
client.architecture_changes
```

## Runner Methods

| Method | Description |
|---|---|
| `introspect` | Build and cache a self-model snapshot |
| `self_narrative` | Build model and generate prose narrative |
| `explain_subsystem` | Description and current state of a specific subsystem |
| `architecture_overview` | Capability map with extension counts per category |
| `health_trend` | Cognitive health scores over last N snapshots |
| `architecture_changes` | Snapshots where extension set changed |
| `metacognition_stats` | Snapshot count, latest health, stale flag |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
