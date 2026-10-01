#!/usr/bin/env bash
# Git forensics for brownfield discovery. Read-only. Safe to run anywhere.
# Usage: ./scripts/git-forensics.sh [months]   (default 12)
set -uo pipefail
M="${1:-12}"
SINCE="${M} months ago"
hr(){ printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "not a git repo"; exit 1; }
git rev-parse HEAD >/dev/null 2>&1 || { echo "git repo has no commits yet — nothing to analyse"; exit 0; }

hr "REPO AGE AND SIZE"
echo "first commit : $(git log --reverse --format=%ad --date=short | head -1)"
echo "last commit  : $(git log -1 --format=%ad --date=short)"
echo "commits      : $(git rev-list --count HEAD)"
echo "contributors : $(git log --format=%an | sort -u | wc -l | tr -d ' ')"
echo "tracked files: $(git ls-files | wc -l | tr -d ' ')"

hr "CHANGE HOT SPOTS — files (last ${M}m)"
git log --format=format: --name-only --since="$SINCE" | sed '/^$/d' | sort | uniq -c | sort -rn | head -40

hr "CHANGE HOT SPOTS — directories (last ${M}m)"
git log --format=format: --name-only --since="$SINCE" | sed '/^$/d' | xargs -n1 dirname 2>/dev/null | sort | uniq -c | sort -rn | head -25

hr "COMMIT VOLUME BY MONTH (eras: look for steps and gaps)"
git log --format=%ad --date=format:%Y-%m | sort | uniq -c | sort -k2

hr "CONTRIBUTOR COHORTS BY QUARTER (eras: who arrived and left)"
git log --format='%ad|%an' --date=format:%Y-%m \
  | awk -F'|' '{split($1,a,"-"); printf "%s-Q%d|%s\n", a[1], int((a[2]-1)/3)+1, $2}' \
  | sort -u | awk -F'|' '{print $1}' | uniq -c

hr "NEW CONTRIBUTORS PER QUARTER (first-ever commit — marks era starts)"
git log --reverse --format='%ad|%an' --date=format:%Y-%m \
  | awk -F'|' '!seen[$2]++ {split($1,a,"-"); printf "%s-Q%d  %s\n", a[1], int((a[2]-1)/3)+1, $2}'

hr "OWNERSHIP / BUS FACTOR (last ${M}m)"
git log --format=%an --since="$SINCE" | sort | uniq -c | sort -rn | head -20

hr "HOTFIXES, REVERTS, EMERGENCIES (last 24m)"
git log --oneline -i --since="24 months ago" \
  --grep=hotfix --grep=urgent --grep=revert --grep=rollback --grep=critical --grep=emergency --grep=asap | head -40

hr "REVERT COUNT (last 12m)"
git log --oneline --grep='^Revert' --since="12 months ago" | wc -l

hr "TAGS / RELEASE CADENCE (latest 30)"
git tag --sort=-creatordate 2>/dev/null | head -30

hr "MERGE PATTERN (last 6m — infers branching strategy)"
git log --oneline --merges --since="6 months ago" | head -30

hr "ACTIVE BRANCHES (by last commit)"
git for-each-ref --sort=-committerdate refs/remotes --format='%(committerdate:short)  %(refname:short)  %(authorname)' | head -25

hr "STALE BRANCHES (no commit in 90 days)"
git for-each-ref --sort=committerdate refs/remotes --format='%(committerdate:short)  %(refname:short)  %(authorname)' \
  | awk -v d="$(date -v-90d +%Y-%m-%d 2>/dev/null || date -d '90 days ago' +%Y-%m-%d)" '$1 < d' | head -25

hr "RECENT ACTIVITY / WIP (last 30d)"
git log --oneline --since="30 days ago" | head -40

hr "DEPENDENCY / FRAMEWORK SHIFTS (manifest history)"
for f in $(git ls-files | grep -Ei '(\.csproj|Directory\.Packages\.props|package\.json|pom\.xml|build\.gradle|go\.mod|requirements\.txt|pyproject\.toml|Cargo\.toml)$' | head -12); do
  echo "--- $f"
  git log --oneline --follow -- "$f" 2>/dev/null | head -8
done

hr "DORMANT AREAS (top-level dirs untouched in ${M}m)"
for d in $(git ls-files | awk -F/ 'NF>1{print $1}' | sort -u); do
  last=$(git log -1 --format=%ad --date=short -- "$d" 2>/dev/null)
  echo "$last  $d"
done | sort | head -20

hr "LARGEST FILES (complexity proxy)"
git ls-files | xargs wc -l 2>/dev/null | sort -rn | sed -n '2,21p'

hr "DEBT MARKERS"
EXCL=(':(exclude)*lock*' ':(exclude)*/node_modules/*' ':(exclude)*/dist/*' ':(exclude)*/bin/*'
      ':(exclude)*/obj/*' ':(exclude)*.min.*' ':(exclude)*.map' ':(exclude)*/vendor/*')
echo "total: $(git grep -wInE '(TODO|FIXME|HACK|XXX|WORKAROUND)' -- . "${EXCL[@]}" 2>/dev/null | wc -l | tr -d ' ')"
echo "by directory:"
git grep -wIlE '(TODO|FIXME|HACK|XXX|WORKAROUND)' -- . "${EXCL[@]}" 2>/dev/null \
  | xargs -n1 dirname 2>/dev/null | sort | uniq -c | sort -rn | head -10
echo "samples:"
git grep -wInE '(TODO|FIXME|HACK|XXX|WORKAROUND)' -- . "${EXCL[@]}" 2>/dev/null | head -15
