# lex-metacognition

Second-order self-model assembly for LegionIO's brain-modeled agentic AI.

## Overview

lex-metacognition enables the agent to build an explicit model of its own architecture, capabilities, and current cognitive state. Unlike lex-reflection (which monitors performance metrics), metacognition assembles a structured self-representation from live runtime introspection — the agent genuinely knowing what it is, what it can do, and what it's doing right now.

## Features

- **Self-Model Assembly**: Discovers loaded extensions, maps capabilities, captures cognitive state
- **Snapshot History**: Maintains rolling history of self-model snapshots with TTL-based caching
- **Architecture Change Detection**: Tracks when extensions are loaded/unloaded across snapshots
- **Health Trending**: Monitors cognitive health over time from accumulated snapshots
- **Natural Language Self-Description**: Bridges self-model to human-readable prose via NarratorBridge
- **Subsystem Explanation**: Can explain what any specific subsystem does and its current state

## Usage

```ruby
client = Legion::Extensions::Metacognition::Client.new

# Build and cache a self-model
model = client.introspect(tick_results: tick_output)

# Get natural language self-description
narrative = client.self_narrative(tick_results: tick_output)
puts narrative[:prose]
# => "I am a brain_modeled cognitive_agent built on LegionIO with 24 extension slots.
#     18 of 24 extensions are active. Operating in full_active mode.
#     Running 12 phases per tick. Cognitive health: excellent (92%)."

# Explain a specific subsystem
info = client.explain_subsystem(subsystem: :memory)

# Track health over time
trend = client.health_trend(limit: 20)
```

## License

MIT
