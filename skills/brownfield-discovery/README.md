# brownfield-discovery

A skill for investigating an unfamiliar codebase fast and writing down what you found.

Drops you into a repository you have never seen and produces a structured `discovery/` folder:
architecture and tiers, git forensics (hot spots, eras, hotfix clusters, ownership, branching),
data and migrations, integrations, quality, observability, risks — plus a draft agent context file
and a ranked list of questions for the humans.

## The one design decision that matters

**It investigates before it reads the documentation.**

Phases 1 to 4 never open `README.md`, `CLAUDE.md`, `AGENTS.md` or `docs/`. Only after its own
findings are written does it read the docs, and then it produces a three-way comparison:
what the docs claim, what the code and history actually say, and a verdict — confirmed, stale,
contradicted, missing, or an undocumented strength. Anything unresolved goes back for another
research pass.

Existing documentation tells you what the authors believed was true, usually some time ago.
An independent read is worth more, and the gap between the two is itself one of the most
useful findings.

## Install

### Claude Code — project
```bash
git clone https://github.com/<you>/brownfield-discovery /tmp/bd
mkdir -p .claude/skills
cp -r /tmp/bd/.claude/skills/brownfield-discovery .claude/skills/
cp -r /tmp/bd/scripts .              # optional, the forensics script
```

### Claude Code — available everywhere
```bash
cp -r /tmp/bd/.claude/skills/brownfield-discovery ~/.claude/skills/
```

Then: `/brownfield-discovery` — or `/brownfield-discovery fast` when time is short.

### No install (ChatGPT, or a locked-down machine)
Paste [`PROMPT.md`](PROMPT.md) into the chat. It is the whole method in one message.

## Modes

| Mode | Phases | Output | Time |
|---|---|---|---|
| Full (default) | all | 12 files | 20–40 min |
| `fast` | 1, 2, 5, 7 | 3 files | 8–12 min |

## Git forensics on its own

```bash
./scripts/git-forensics.sh 12    # months of history, default 12
```

Read-only. Hot spots, commit volume by month, contributor cohorts, bus factor, hotfix and revert
clusters, release cadence, merge patterns, active and stale branches, dependency shifts,
dormant areas, largest files, debt markers.

## Why the outputs are split by topic

One giant report is unreadable and unusable in a conversation. Separate files let you open the
one you need, hand a single file to someone else, and diff them on a later pass.

## Licence

MIT.
