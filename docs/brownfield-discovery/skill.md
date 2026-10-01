---
name: brownfield-discovery
description: Systematically investigate an unfamiliar (brownfield) codebase and produce a structured discovery report plus a proposed agent context file. Use when dropped into a repository you do not know and need to understand its architecture, history, risks, integrations and operational readiness fast. Investigates independently FIRST, then reconciles against any existing documentation to avoid inheriting its blind spots.
---

# Brownfield Discovery

Investigate an unfamiliar codebase and write a structured, evidence-based discovery set into `discovery/`.

## Core principle: investigate before you read the docs

**Phases 1 to 4 must be completed WITHOUT reading any prose documentation.** Do not open `README.md`, `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `docs/`, wikis, or any root-level `.md` file until Phase 5.

Why: existing documentation anchors you. It tells you what the authors *believe* is true, which is often what *was* true. Your value is an independent read of what the code and history actually say. Only after your own findings are written down do you open the docs — and then the difference between the two is itself a finding.

Reading `.md` files inside source folders is allowed when they are code-adjacent (e.g. a migration note beside a migration). When in doubt, defer it to Phase 5.

## Operating modes

- **Full** (default): all phases, all output files. Budget 20 to 40 minutes.
- **Fast**: pass `fast` in the arguments. Phases 1, 2, 5 and 7 only, and write just `00-summary.md`, `01-architecture.md`, `10-open-questions.md`. Budget 8 to 12 minutes. Use under time pressure.

Announce which mode you are in and roughly how long it will take before starting.

## Phase 0 — setup

1. Create `discovery/`.
2. Confirm it is a git repository (`git rev-parse --is-inside-work-tree`). If not, skip Phase 2 and say so.
3. Identify the ecosystem from manifest files only: `*.sln`, `*.csproj`, `Directory.Packages.props`, `package.json`, `pom.xml`, `build.gradle`, `go.mod`, `requirements.txt`, `pyproject.toml`, `Cargo.toml`, `Gemfile`.
4. Note repository size, file count and top-level layout.

Write nothing yet. Keep notes.

## Phase 1 — blind reconnaissance

Goal: what is this, what does it expose, how is it layered.

- **Entry points.** `Program.cs`, `Startup.cs`, `Main`, controllers, minimal API endpoint registrations, function triggers, hosted services, console entry points, message consumers, cron or timer jobs.
- **Tiers.** Identify the layers present: presentation, API, application or use-case, domain, infrastructure, storage. Note which are real and which are nominal (a folder called `Domain` full of DTOs is nominal).
- **Module boundaries.** Projects, packages or top-level folders. Are they organised by technical layer or by business capability? Say which, because it predicts almost everything else.
- **Seams.** Every place the system touches something it does not own: HTTP clients, SDK usage, message brokers, database contexts, file shares, caches, identity providers.
- **Dependency direction.** Do inner layers reference outer ones? Note every violation you can see from project references or imports.
- **Naming and vocabulary.** Collect the recurring domain nouns. Note where the same concept has two names, or one name has two meanings.

Produce the ASCII diagrams described in the Output section.

## Phase 2 — git forensics

Run the commands in `scripts/git-forensics.sh` (or inline equivalents). Interpret, do not just paste output.

- **Change hot spots.** Files and directories with the highest churn over 12 months. These concentrate both risk and knowledge. Cross-reference with test coverage: high churn plus no tests is your top risk.
- **Eras.** Reconstruct the repository's history in periods. Look for contributor cohorts arriving and leaving, framework or package migrations, directory creation and abandonment, naming-convention shifts. Name each era and say what it was trying to do. This is the most useful and most-skipped part of the analysis.
- **Where effort went.** Which directories absorbed the most commits per era.
- **Ownership and bus factor.** Contributors per directory over 12 months. Flag any significant area with exactly one recent contributor.
- **Hotfixes, reverts and incidents.** Commits matching hotfix, urgent, revert, rollback, critical, emergency. Cluster them by area and by time. Clusters mark fragile subsystems and past incidents.
- **Release and branching.** Tags and their cadence, merge patterns, long-lived branches, naming conventions. Infer the branching strategy rather than assuming one.
- **Work in progress.** Branches active in the last 60 days, with author and last commit date. Stale feature branches over 90 days are a finding.
- **Dormancy.** Areas untouched for over a year: either stable or abandoned. Distinguish by whether they are still referenced.

## Phase 3 — data and integrations

- **Storage.** Engines in use. Schema location: migrations, database project, ORM model, or hand-rolled SQL.
- **Migration approach.** Tool (EF Core migrations, DbUp, Flyway, Liquibase, SQL project or DACPAC, none), where migrations live, whether they run at deploy or by hand, whether they are reversible, and whether there is a seeding path.
- **Conventions.** Naming of tables and columns, pluralisation, key strategy (identity, sequence, GUID, composite), soft deletes, audit columns, temporal or history tables, timezone handling, money representation, enum storage. Note inconsistencies, they usually mark era boundaries.
- **Integration points.** For each external system: direction, transport, authentication, data shape, error handling, retry policy, whether a translation layer exists or the foreign model leaks into the domain.
- **Contracts.** Event or message schemas, versioning approach, whether an envelope carries version, correlation identifier and timestamp.

## Phase 4 — quality, risk and operability

- **Tests.** What exists by type. Where the gaps sit relative to the hot spots from Phase 2. How tests are run. Whether they are deterministic. Do not report a coverage percentage as a conclusion; report confidence in the paths that matter.
- **Build and deploy.** Pipeline definitions, environments, deployment unit, rollback mechanism, whether infrastructure is coded.
- **Observability.** Logging approach and whether it is structured; correlation identifier propagation and whether it survives across tiers and across async or message boundaries; metrics; health checks; tracing; what is alerted on, and crucially whether alerts are on **business signals** (orders unacknowledged, queue age, payment failure rate) or only on **infrastructure** (processor, memory, restarts). State which predominates, with evidence.
- **Security.** Secret handling, authentication and authorisation model, input validation at boundaries, known-vulnerable dependencies, anything hard-coded. Report classes of problem, never a working exploit.
- **Technical debt.** Inventory with evidence: duplication, god classes, dead code, suppressed warnings, TODO and HACK density, pinned or abandoned dependencies, framework versions past support. For each, note the carrying cost and what it blocks.

## Phase 5 — context reconciliation

Only now, read the documentation: `README`, `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.github/copilot-instructions.md`, `docs/`, ADR folders, wikis, onboarding guides.

Produce a three-way comparison for every material claim:

| Existing docs say | Code and history say | Verdict |
|---|---|---|

Verdicts are: **confirmed**, **stale** (was true, no longer), **contradicted**, **missing** (docs silent where it matters), or **undocumented strength** (something good the docs never mention).

Give the documentation an honest agent-readiness assessment: could an agent act correctly using only this? What would it get wrong?

## Phase 6 — targeted re-research

The comparison will surface things you cannot yet resolve. For each one, go back into the code and settle it. Loop until every item is either resolved with evidence or explicitly listed as an open question for a human. Do not leave a contradiction unexamined.

## Phase 7 — synthesis

Write the outputs. Then produce:

1. **A proposed context file** (`discovery/AGENTS.proposed.md`) containing: what the system is, the architecture in a paragraph plus a diagram, domain vocabulary, module boundaries and their rules, build, test and run commands that actually work, conventions an agent must follow, **what must not be touched and why**, and where the landmines are.
2. **Open questions** ranked by how much the answer would change your plan.

## Output files (in `discovery/`)

| File | Contents |
|---|---|
| `00-summary.md` | The ten things that matter, top five risks, and a one-paragraph verdict on the system's health |
| `01-architecture.md` | Tiers, entry points, module map, seams, ASCII diagrams |
| `02-stack.md` | Languages, frameworks, versions, support status, dependency inventory |
| `03-history.md` | Hot spots, eras, ownership, hotfix clusters, releases, branching, work in progress |
| `04-data.md` | Storage, schema, migrations, conventions, inconsistencies |
| `05-integrations.md` | External systems, contracts, translation layers, coupling assessment |
| `06-quality.md` | Tests, build, deploy, rollback |
| `07-observability.md` | Logging, correlation, metrics, alerting, business versus infrastructure signals |
| `08-risks.md` | Security and technical debt, each with evidence, cost and what it blocks |
| `09-context-delta.md` | The Phase 5 comparison table and agent-readiness assessment |
| `10-open-questions.md` | Ranked questions for the humans |
| `AGENTS.proposed.md` | The draft context file |

Every file starts with a two-line summary so it can be read alone.

## Required diagrams

Keep them redrawable by hand in under two minutes.

**Folder structure** — annotated, purpose per top-level entry, not a raw tree.

**Tiers**
```
┌─────────────────────────────────────┐
│  UI / Storefront                     │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  API / Controllers                   │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  Application / Use cases             │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  Domain                              │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  Infrastructure ──► Storage / Queues │
└─────────────────────────────────────┘
```
Mark every dependency that points the wrong way with an arrow and a note.

**Module dependency graph** — boxes and arrows between projects or packages; mark cycles explicitly.

**Integration map** — this system in the middle, external systems around it, arrows showing direction and transport, and a mark on each boundary showing whether a translation layer exists.

## Rules

- **Evidence over impression.** Every claim cites a path, a command output or a commit. If you are inferring, write "inferred" and say from what.
- **Separate observation from recommendation.** Findings first; advice clearly labelled.
- **Quantify where you can.** Counts, dates, versions, commit numbers.
- **No moralising about code quality.** Describe cost and risk, not aesthetics.
- **Say what you did not look at**, and why. An honest coverage statement makes the rest credible.
- **Security findings describe the class of problem**, never a working exploit.
