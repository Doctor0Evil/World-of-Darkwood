World‑of‑Darkwood is the canonical, engine‑first world bible and content hub for a multi‑biome, multi‑era survival‑horror universe that aims to be deeper, more systemic, and more reactive than traditional MMO worlds while retaining the unforgiving tension of top‑down horror. It treats regions, NPCs, creatures, skills, traits, perks, and classes as data‑driven assets wired into a unified horror engine, not as disconnected content drops.

***

## Project Scope

World‑of‑Darkwood serves as:

- A hierarchical world layout for forests, swamps, villages, ruins, towers, liminal spaces, and beyond, designed to stream regions and psychological states dynamically.  
- A shared schema for tilesets, creatures, characters, and story encounters with strict, reusable templates for all branches.  
- The reference repository for player progression (attributes, skills, traits, perks, and three core classes), wired to ALN/Web5‑DID progression tracking.

It is not a single game; it is the backbone for multiple survival‑horror experiences, including a top‑down Darkwood‑style sequel, AI‑driven scenarios, and RPG‑lite experiments, all grounded in the same rules.

***

## Core Engine Links

World‑of‑Darkwood organizes horror systems as durable engine modules:

- `engine/world/WorldMemoryCore` – logs betrayals, deaths, Twin‑style residues, and chapter‑scale events for later reference in dialogue, encounters, and ambient anomalies.  
- `engine/world/ContaminationSpiral` – manages infection thresholds (0.15, 0.35, 0.55, 0.85) and their effects: voice mirroring, NPC anomalies, hallucinations, and world geometry shifts.  
- `engine/world/GlobalMoodTensor` – tracks fear, despair, chaos, and hope to steer encounter intensity, audio design, and sanity events.  
- `systems/SanitySystem` – defines uneasy, disturbed, shaken, and breaking bands; drives collapse events and perception distortions.  
- `engine/npc/AIStateMachines` – declarative FSMs that enforce consistent hooks like `onPlayerApproach`, `onTradeRequest`, and `onThreat`.  
- `engine/npc/PersonalitySystem` – personality vectors using a large trait set (Friendly, Cunning, Cruel, Sneaky, Mad, etc.) to parameterize all NPC and creature behavior.

All content templates in this repo are expected to link back into these core modules.

***

## Session Template for Continuous Progress

Every coding or design session in this repo starts with a standard header so that IDE agents and humans can always pick up exactly where they left off:

```text
SESSION_HEADER
  session_id: <YYYY-MM-DD_HHMM_env-branch>
  engine_branch: <engine/world | engine/npc | systems | game/configs>
  focus_domain: <tilesets | creatures | characters | stories | sanity | contamination | AI>
  last_checkpoint_ref: <file path + anchor or commit/tag>
  next_milestone: <short, concrete goal for this session>
```

Persistent systems are referenced explicitly:

```text
PERSISTENT_STATE_LINKS
  world_memory_core_ref: engine/world/WorldMemoryCore
  contamination_spiral_ref: engine/world/ContaminationSpiral
  global_mood_tensor_ref: engine/world/GlobalMoodTensor
  sanity_system_ref: systems/SanitySystem
  ai_state_machines_ref: engine/npc/AIStateMachines
  personality_system_ref: engine/npc/PersonalitySystem
```

Each session documents which tilesets, creatures, characters, encounters, and engine hooks were created or modified, plus a concrete `next_session_entry_point` so there is never a “blank page” moment.

***

## Content Definition Templates

World‑of‑Darkwood standardizes authoring through four primary infobox‑style blocks. These are used in wiki docs, ALN scripts, and config files alike.

### Tilesets

Tilesets define the visual and hazard profile of a region:

```text
TILESET_DEFINITION_BLOCK
  template: {{tilesetbox}}
  fields:
    name: <Tileset name>
    biome: forest | swamp | village | interior | sewer | ruins | tower
    style: scratchy | desaturated | fungal | ruinous | occult | spectral
    lighting_profile: dim | flicker | neon | occult | shadowed
    hazard_tags: contamination | trap | ambush | sanity_drain | infection | spectral_presence
    rarity: common | rare | unique
    story_hooks: <encounter/NPC references tied to this tileset>
  working_entry:
    {{tilesetbox
    | name = <WIP_TilesetName>
    | biome = <biome>
    | style = <style>
    | lighting_profile = <lighting_profile>
    | hazard_tags = <mma_separated_tags>
    | rarity = <rarity>
    | story_hooks = <NPCs/encounters>
    }}
```

Tilesets are then hooked into `VisionConeSystem` for FOV rules and into hazard controllers per biome.

### Creatures

Creatures are systemic horrors with explicit sanity and folklore parameters:

```text
CREATURE_DEFINITION_BLOCK
  template: {{creaturebox}}
  fields:
    id: <Unique identifier>
    category: monstrosity | abomination | specter | demonic | undead | folkloric
    folklore_root: forest_crone | marsh_spirit | fungus_spirit | ancestor | spectral
    rarity: <0.0–1.0>
    sanity_profile: shock:<0–1>, lingering:<0–1>, body:<0–1>, surreal:<0–1>
    morphology: <body/head/limbs/movement descriptors>
    behavior: ambient | stalker | ambush | trap | infection
    audio: whispers | bone_crack | thread_snap | echo | humming
    personality_vector: <trait weights e.g. Cruel:0.8, Cunning:0.7, Furtive:0.9>
    story_links: <encounters or rituals>
  working_entry:
    {{creaturebox
    | id = <WIP_CreatureId>
    | category = <egoryy>
    | folklore_root = <folklore_root>
    | rarity = <rarity_float>
    | sanity_profile = shock:<v>, lingering:<v>, body:<v>, surreal:<v>
    | morphology = <short description>
    | behavior = <behavior>
    | audio = <mma_separated_audio>
    | personality_vector = <trait:value, ...>
    | story_links = <linked_encounters>
    }}
```

These entries feed `Beastiary` modules and spawn matrices that respect contamination, sanity, and global mood.

### Characters (NPCs)

Characters are horror archetypes with personality‑driven AI:

```text
CHARACTER_DEFINITION_BLOCK
  template: {{characterbox}}
  fields:
    name: <NPC name>
    role: villager | antagonist | spectral | trader | guide
    traits: <trait weights: cunning, cruel, furtive, mad, pensive, etc.>
    dialogue_tree: <ALN file ref, e.g. configs/npc_profiles/Name/dialogue_tree.aln>
    encounters: <ALN file ref, e.g. configs/npc_profiles/Name/encounters.aln>
    sanity_cost: <min–max>
    rarity: common | rare | unique
    story_hooks: <narrative arcs tied to this NPC>
  working_entry:
    {{characterbox
    | name = <WIP_NPCName>
    | role = <role>
    | traits = <trait:value, ...>
    | dialogue_tree = <path/to/dialogue_tree.aln>
    | encounters = <path/to/encounters.aln>
    | sanity_cost = <min–max>
    | rarity = <rarity>
    | story_hooks = <arcs>
    }}
```

Implementation paths are explicitly listed for IDE agents in `NPC_IMPLEMENTATION_BLOCK` with per‑file goals.

### Story Encounters

Encounters attach narrative and mechanical spikes to contamination, sanity, or NPC triggers:

```text
STORY_ENCOUNTER_DEFINITION_BLOCK
  template: {{storybox}}
  fields:
    title: <Encounter title>
    location: <biome or interior>
    trigger: contamination:<threshold> | sanity_collapse:<band> | npc_interaction:<id> | rare_spawn:<tag>
    scripts: <ALN/Lisp file ref, e.g. game/scripts/EncounterScripts/name.aln>
    outcome: sanity_loss:<value> | contamination_spike:<value> | npc_betrayal:<id> | rare_boon:<id> | lingering_dread:<tag>
    rarity: common | rare | unique
    linked_tilesets: <tilesets where encounter manifests>
    linked_creatures: reatures tied to encounter>
  working_entry:
    {{storybox
    | title = <WIP_EncounterTitle>
    | location = <location>
    | trigger = <trigger_condition>
    | scripts = <path/to/script.aln>
    | outcome = <mma_separated_outcomes>
    | rarity = <rarity>
    | linked_tilesets = <tileset_ids>
    | linked_creatures = <eature_ids>
    }}
```

Outcomes must always thread back into `WorldMemoryCore`, `SanitySystem`, and `ContaminationSpiral`.

***

## Player Progression Model

World‑of‑Darkwood defines a strict, anti‑exploit progression framework inspired by the original game’s skills and traits, but expanded into four clearly separated layers: attributes, skills, traits, and perks.

### Attributes (Innate Stats)

Attributes are core, slow‑changing properties that shape the character’s body and mind. They never level from spamming actions; they rise only from major milestones, rare books, or scripted events.

Suggested attribute set:

- Strength – physical force; melee carry capacity, shove power.  
- Endurance – stamina pool, resistance to exhaustion and bleed.  
- Agility – movement responsiveness, dodge windows, recoil control.  
- Perception – sensory acuity; sight radius, hearing thresholds (not “Awareness” as a skill).  
- Intelligence – reasoning and technical understanding; affects certain crafting and ritual checks.  
- Willpower – resistance to sanity loss, curses, and psychic pressure.  
- Luck – systemic bias for edge‑case outcomes (loot rolls, misfires, miracle survivals).

Attributes are the base that traits and perks modify; they are not treated as skills. Luck is explicitly an attribute, not a skill.

### Skills (Learned Proficiencies)

Skills are discrete, 0–100 integer tracks that unlock options and efficiencies, never raw “more damage” or “more HP” in a way that trivializes horror. They improve only through:

- Unique events (e.g., first time disarming a complex trap type).  
- Major quest completions with skill tags.  
- Reading specific books or training from rare NPCs.

No action can be repeated for XP: every trigger is strictly one‑time or tightly contextual to prevent grinding or farming.

Example universal skills:

- Scavenging – quality and variety of loot found, not value inflation.  
- Survival – camp setup, fire use, field repairs.  
- Stealth – noise footprint, visibility thresholds.  
- Lockpicking – success chances and mishap severity.  
- Medicine – healing efficiency, treatment safety.  
- Melee Combat – handling stability, recovery times; no bullet‑sponge creation.  
- Ranged Combat – recoil control, reload smoothness, jamming odds.  
- Bartering – price adjustment and offer variety (in combination with attributes and reputation).  
- Crafting – base mechanical assembly and upgrades.  
- Chemistry – explosives, drugs, and complex brews.  
- Trapping – trap complexity and disarm safety.  
- Perception Training – extending practical use of Perception attribute (e.g., spotting traps, tells).  
- Exploration – map annotation, route recall, non‑magical navigation improvements.  
- Focus – resistance to panic in combat, slower aim sway under stress.  
- Tinkering – repair depth and customization of gear.

Skill progression is slow and steep in its upper range, echoing harsh games where maxing a skill is a long‑term aspiration, not a default expectation.

### Traits (Permanent Trade‑Off Modifiers)

Traits modify primary and derived stats and skills with explicit pros and cons. There are no purely positive traits.

- Gained at key progression events (e.g., essence injections, story rites, trauma thresholds), not at will.  
- Each trait has at least one meaningful upside and one meaningful downside.  
- Traits can reference attributes and skills to create playstyle forks (e.g., “+Willpower, −Charisma equivalent, +Sanity loss from specific horrors”).

Examples:

- Iron Lungs: +Endurance, −Stealth in tight spaces due to heavier breathing sounds.  
- Fungal Tolerance: +resistance to certain toxins, −susceptibility to specific cures or light‑based effects.  
- Cold‑Soaked: +resistance to cold events, −slower healing from burns and physical trauma.

### Perks (Milestone Powers)

Perks are special enhancements chosen every fifth player level, with:

- 20 global perks plus 1 unique, class‑specific perk per class.  
- Some perks offering multiple ranks, each rank providing incremental benefit.  
- Hard requirements on attributes and skills; drugs can temporarily raise stats to experiment, but perks cannot be permanently unlocked while stats are drug‑inflated.

Perks must:

- Add tactical variety (alternative attacks, riskier rituals, mobility options).  
- Avoid over‑inflating damage or HP; combat stays lethal, as in the original game.

### ALN/Web5‑DID Progression Tracking

All progression events (attribute gains, skill increases, trait assignments, perk picks) are mirrored to ALN’s blockchain:

- Each unlock is recorded as a micro‑transaction tied to a Web5‑DID.  
- Costs are negligible and effectively invisible to the player; owning a single ALN token is enough for a lifetime of progression.  
- On‑chain history helps prevent tampering and supports persistent identity across runs while remaining UX‑transparent.

***

## Character Classes for Darkwood 2

World‑of‑Darkwood defines three asymmetric but carefully constrained classes intended for survival‑horror, not power fantasies. They are primarily about flavor, unique interactions, and alternative problem‑solving, not DPS races.

### Voltborn – Electric Survivor

Concept: Draws vitality and power from electrical fields; channels energy into close‑quarters combat and device manipulation.

Core properties:

- Attribute bias: +Strength, +Endurance, moderate +Intelligence; slight −Willpower due to psychological strain.  
- Passive: Slowly regenerates HP (e.g., 1–5 HP/sec) when near active electrical sources (lamps, generators, sparking machinery) within safe bounds.  
- Utility: Enhanced interaction with terminals and machinery (shortcuts, alternative routes, trap disarms).  
- Weakness: Increased vulnerability to magnetized, psychic, or spiritually‑charged attacks (Twin abilities, certain ghost events, corrupted electronics).

Voltborn traits and perks carry psychological risk: specific perks raise contamination or sanity stress under overload, motivating use of drugs like Neural‑Stimuli to keep sanity in check without trivializing horror.

### Rotkin – Mold‑Touched Survivor

Concept: A mutated survivor whose blood hosts a regenerative mold, echoing the original’s essence system but re‑anchored to a class fantasy.

Core properties:

- Attribute bias: +Endurance, +Willpower; slight −Agility.  
- Resistances: Passive +percentage resistance to fungal and spore‑based poisons and infections.  
- Weakness: Severe vulnerability to fire (e.g., +75% damage from fire and certain heat hazards).  
- Progression: Exclusive ability to use “mushroom‑growth” nodes for class‑specific progression; other classes cannot consume or channel these growths in the same way.  
- Ecology: Can communicate with certain animals (e.g., fox‑like or carrion creatures) to gain diegetic hints, side‑quest hooks, or restricted barter opportunities with quest NPCs.  
- Necro‑fungal Raise: Once per in‑game day, can animate 1–3 fresh corpses (not burned or destroyed) as fungal thralls that fight until their HP is depleted or they are incinerated; this is a strategic tool, not a permanent army.

Rotkin leans into world interaction and emergent tactics rather than direct stat dominance, preserving danger and fragility.
### WraithLink – Haunted Medium

Concept: The most “human” class, partially merged with spirits, used for intel, lore, and cursed risk‑reward.

Core properties:

- Attribute bias: +Perception, +Willpower, average physicals.  
- Ghost Affinity: Does not reduce the frequency or lethality of ghost encounters; instead, substantially increases the odds (+% chance) of contact events and spectral anomalies.  
- Spirit Dialogue: Can talk to certain dead NPCs or spirits to glean extra narrative, alternate quest solutions, and unique warnings.  
- Cursed Relics: Higher chance to find cursed relics—rare, highly valuable items that inflict ongoing paranormal events while held (hauntings, pursuit, ambient threats).  
- Social Risk: When attempting to trade or display cursed relics in settlements, there is a chance that hidden forces (e.g., Twin influence) cause villagers to become hostile or mind‑controlled, turning a normal sale into an ambush event.

WraithLink pushes players into “knowledge vs safety” dilemmas: more intel and shortcuts at the cost of escalated supernatural pressure.

***

## Engine Linkage & Session Tracking

All class, progression, and content work is anchored with:

```text
ENGINE_LINKAGE_BLOCK
  world:
    WorldMemoryCore:
      logs: <which events this session adds (deaths, betrayals, chaos overloads)>
      hooks: <NPCs/encounters that will reference these logs>
    ContaminationSpiral:
      thresholds_touched: <0.15 | 0.35 | 0.55 | 0.85>
      effects: <voice_mirroring | npc_anomalies | hallucinations>
    GlobalMoodTensor:
      target_shift_this_session:
        fear: <Δ>
        despair: <Δ>
        chaos: <Δ>
        hope: <Δ>
  systems:
    SanitySystem:
      thresholds_used: <uneasy | disturbed | shaken | breaking>
      new_triggers: <sanity_collapse hooks updated>
    VisionConeSystem:
      tileset_links: <which tilesets enforce which FOV rules>
```

NPC implementation work is scoped via:

```text
NPC_IMPLEMENTATION_BLOCK
  files_to_touch:
    - game/configs/npc_profiles/<name>/npc_meta.json
    - game/configs/npc_profiles/<name>/personality.aln
    - game/configs/npc_profiles/<name>/dialogue_tree.aln
    - game/configs/npc_profiles/<name>/encounters.aln
    - engine/npc/ai_profiles/<name>_ai.gd
  per-file goals this session:
    npc_meta.json: <add/extend identity, hooks>
    personality.aln: <adjust trait vectors>
    dialogue_tree.aln: <add branches, conditions>
    encounters.aln: <implement or refine encounter scripts>
    <name>_ai.gd: <state machine adjustments>
```

Session logs track created/modified assets, tests, and the exact next entrypoint for future work:

```text
SESSION_PROGRESS_TRACKING
  today_created:
    tilesets: [<ids>]
    creatures: [<ids>]
    characters: [<names>]
    encounters: [<titles>]
    engine_hooks: [<WorldMemory | Sanity | Contamination updates>]
  today_modified:
    configs: [<file paths>]
    scripts: [<file paths>]
  tests_run:
    - <test_name> → pass/fail + notes
  open_issues:
    - <short description + file_ref>
  next_session_entry_point:
    focus_domain: <what to pick up next time>
    primary_file: <path/to/file>
    cursor_hint: <section/tag to jump to>
    required_context:
      - <brief reminders or design decisions that must be remembered>
```


