# lex-metacognition

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-metacognition`
- **Version**: `0.1.1`
- **Namespace**: `Legion::Extensions::Metacognition`

## Purpose

Second-order self-model assembly for LegionIO agents. Introspects the agent's own architecture at runtime — discovers loaded extensions, maps them to capability categories, captures cognitive state from tick results, and builds a snapshot of what the agent is, what it can do, and how it is currently performing. Maintains a rolling snapshot history for health trending and architecture change detection. Bridges the self-model to human-readable prose via NarratorBridge.

## Gem Info

- **Require path**: `legion/extensions/metacognition`
- **Ruby**: >= 3.4
- **License**: MIT
- **Registers with**: `Legion::Extensions::Core`

## File Structure

```
lib/legion/extensions/metacognition/
  version.rb
  helpers/
    constants.rb          # SUBSYSTEMS (100+), CAPABILITY_CATEGORIES, EXTENSION_CAPABILITIES (200+ mappings), HEALTH_LABELS
    self_model.rb         # SelfModel builder
    snapshot_store.rb     # Rolling snapshot history
    narrator_bridge.rb    # Self-model to prose conversion
  runners/
    metacognition.rb      # Runner module

spec/
  legion/extensions/metacognition/
    helpers/
      constants_spec.rb
      self_model_spec.rb
      snapshot_store_spec.rb
      narrator_bridge_spec.rb
    runners/metacognition_spec.rb
  spec_helper.rb
```

## Key Constants

```ruby
MAX_SNAPSHOTS  = 50
SNAPSHOT_TTL   = 30   # seconds; snapshots older than this are considered stale

CAPABILITY_CATEGORIES = %i[
  perception cognition memory motivation safety
  communication introspection coordination
]

# SUBSYSTEMS: 100+ symbols covering all cognitive subsystems from tick to
# cognitive_garden. See helpers/constants.rb for the full list.

# EXTENSION_CAPABILITIES: maps 200+ extension constant names (e.g. :Memory, :GoalManagement)
# to their capability category (:memory, :motivation, etc.)

HEALTH_LABELS = {
  (0.8..)     => :excellent,
  (0.6...0.8) => :good,
  (0.4...0.6) => :fair,
  (0.2...0.4) => :degraded,
  (..0.2)     => :critical
}
```

## Helpers

### `Helpers::SelfModel` (class)

Builds a point-in-time snapshot of the agent's own state.

SelfModel snapshot structure:
```ruby
{
  id:              String (UUID),
  timestamp:       Time,
  loaded_extensions: Array<Symbol>,      # via Legion::Extensions.constants
  capability_map:  Hash<Symbol, Array>,  # category -> [extension names]
  active_count:    Integer,
  total_slots:     Integer,
  tick_mode:       Symbol,               # from tick_results or :unknown
  phase_count:     Integer,
  cognitive_health: Float,               # derived from phase success rates
  subsystem_states: Hash<Symbol, Hash>   # subset of SUBSYSTEMS with available data
}
```

Key methods:
- `build(tick_results:)` — assembles snapshot from runtime introspection
- `cognitive_health` — ratio of phases that completed successfully in tick_results
- `capability_map` — groups loaded extensions by EXTENSION_CAPABILITIES category

### `Helpers::SnapshotStore` (class)

Rolling history of self-model snapshots.

| Method | Description |
|---|---|
| `store(snapshot)` | appends snapshot; evicts oldest when over MAX_SNAPSHOTS |
| `latest` | most recent snapshot |
| `stale?` | true if latest snapshot is older than SNAPSHOT_TTL seconds |
| `health_trend(limit:)` | cognitive_health values from last N snapshots |
| `architecture_changes` | snapshot pairs where loaded_extensions sets differ |

### `Helpers::NarratorBridge` (module/class)

Converts a self-model snapshot into human-readable prose.

| Method | Description |
|---|---|
| `narrate_self_model(model)` | returns { prose: String, model: snapshot } |

Example prose output:
```
"I am a brain_modeled cognitive_agent built on LegionIO with 24 extension slots.
18 of 24 extensions are active. Operating in full_active mode.
Running 12 phases per tick. Cognitive health: excellent (92%)."
```

## Runners

Module: `Legion::Extensions::Metacognition::Runners::Metacognition`

Private state: `@store` (memoized `SnapshotStore`) and `@bridge` (memoized `NarratorBridge`).

| Runner Method | Parameters | Description |
|---|---|---|
| `introspect` | `tick_results: {}` | Build and cache a self-model snapshot |
| `self_narrative` | `tick_results: {}` | Build model + generate prose narrative |
| `explain_subsystem` | `subsystem:` | Describe a specific subsystem and its current state |
| `architecture_overview` | (none) | Capability map with extension counts per category |
| `health_trend` | `limit: 10` | Cognitive health over last N snapshots |
| `architecture_changes` | (none) | Snapshots where extension set changed |
| `metacognition_stats` | (none) | Snapshot count, latest health, stale?, top capability category |

## Integration Points

- **lex-tick**: `introspect` is called in `post_tick_reflection` phase with tick_results to capture the current cognitive state snapshot.
- **lex-narrator**: NarratorBridge uses the same prose patterns as lex-narrator; when lex-narrator is loaded, metacognition can delegate prose generation to it.
- **lex-cortex**: cortex's runtime extension discovery uses similar `const_defined?` logic; metacognition reads the same `Legion::Extensions` namespace to build its capability map.
- **lex-reflection**: reflection monitors performance metrics; metacognition assembles the structural self-model. Both contribute to the agent's self-awareness.

## Development Notes

- `EXTENSION_CAPABILITIES` maps over 200 extension constant names to capability categories. It is the authoritative registry for what each LEX capability is classified as.
- `SUBSYSTEMS` contains 100+ symbols representing all known cognitive subsystems. It is used for self-model completeness checking — subsystems not in `SUBSYSTEMS` are not introspected.
- Self-model building uses `Legion::Extensions.constants` which returns all loaded constant names. Extensions that have been `require`d but not yet activated are still listed.
- `cognitive_health` is the ratio of tick phases that returned `{ status: :ok }` or similar success states. Phases returning `:no_handler` or error states reduce the health score.
- Snapshot TTL of 30 seconds means `stale?` is true very quickly during normal operation. Callers that cache the latest snapshot should re-introspect each tick.
- The prose template in NarratorBridge is hardcoded. It does not use lex-llm.
