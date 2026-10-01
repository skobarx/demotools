# Brownfield discovery — single prompt

Paste this into any assistant that can read the repository.

---

You are investigating a codebase you have never seen. Produce a structured discovery set in a
`discovery/` folder. Work from evidence: every claim cites a path, a command output or a commit.
Where you infer, say "inferred" and say from what.

**Critical constraint — do not read the documentation yet.** Until step 5 you must not open
`README.md`, `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `docs/`, wikis, or any root-level
markdown. Existing docs describe what the authors believed, often some time ago, and reading them
first will anchor you. Form your own picture, write it down, and only then compare.

Tell me which mode you are running and how long you expect to take. Fast mode is steps 1, 2, 5, 7
and three output files; full mode is everything.

**1. Blind reconnaissance.** Entry points. Which tiers genuinely exist (presentation, API,
application, domain, infrastructure, storage) and which are nominal. Whether modules are organised
by technical layer or by business capability. Every seam where the system touches something it does
not own. Dependency directions and every violation. The recurring domain vocabulary, including any
word that carries two meanings.

**2. Git forensics.** Change hot spots by file and directory over twelve months, cross-referenced
with test coverage — high churn with no tests is the top risk. Reconstruct the repository's eras
from contributor cohorts, framework and package migrations, and directory creation or abandonment;
name each era and say what it was trying to do. Ownership and bus factor per area. Clusters of
hotfix, revert, urgent and rollback commits, which mark fragile subsystems and past incidents.
Release cadence, merge patterns and the branching strategy you can infer. Branches active in the
last sixty days, and stale ones beyond ninety. Areas dormant for over a year.

**3. Data and integrations.** Storage engines. Where the schema lives and how migrations are
applied, whether they are reversible, and whether they run automatically. Conventions: naming,
keys, soft deletes, audit columns, timezone handling, money, enums — and every inconsistency,
because inconsistencies usually mark era boundaries. For each external system: direction,
transport, authentication, error handling, retries, and whether a translation layer exists or the
foreign model leaks into the domain. Message and event contracts, versioning, and whether the
envelope carries a version, a correlation identifier and a timestamp.

**4. Quality, risk and operability.** Tests by type, and where the gaps sit relative to the hot
spots; report confidence in the paths that matter rather than a coverage percentage. Build,
deployment, environments and the rollback mechanism. Observability: whether logging is structured,
whether a correlation identifier survives across tiers and across async or message boundaries,
what metrics and health checks exist, and — state this explicitly with evidence — whether alerting
is on business signals or only on infrastructure. Security by class of problem, never a working
exploit. Technical debt with its carrying cost and what it blocks.

**5. Now read the documentation.** For every material claim, produce a table: what the docs say,
what the code and history say, and a verdict of confirmed, stale, contradicted, missing, or
undocumented strength. Then assess honestly whether an agent could act correctly using only the
existing documentation, and what it would get wrong.

**6. Re-research.** The comparison will surface things you cannot resolve. Go back into the code
and settle each one. Loop until every item is resolved with evidence or explicitly listed as a
question for a human. Leave no contradiction unexamined.

**7. Write the outputs.** Split by topic, each file opening with a two-line summary so it can be
read alone: `00-summary.md`, `01-architecture.md`, `02-stack.md`, `03-history.md`, `04-data.md`,
`05-integrations.md`, `06-quality.md`, `07-observability.md`, `08-risks.md`,
`09-context-delta.md`, `10-open-questions.md`, and `AGENTS.proposed.md`.

The proposed context file must contain what the system is, the architecture in a paragraph and a
diagram, the domain vocabulary, module boundaries and their rules, build and test commands that
actually work, the conventions an agent must follow, what must not be touched and why, and where
the landmines are.

Include hand-drawable ASCII diagrams: an annotated folder structure, a tier diagram marking every
dependency that points the wrong way, a module dependency graph marking cycles, and an integration
map showing direction, transport and whether each boundary has a translation layer.

Finish by saying what you did not look at, and why.
