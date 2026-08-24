#!/usr/bin/env bash
#
# bind-to-extraction.sh
# Helper that reads _reversa_sdd/ and returns JSON with canonical sources for forward skills.
# Reversa principle: forward skills never start from zero; reasoning stays anchored to reverse-pipeline artifacts.
#
# Uso:
#   bind-to-extraction.sh [--json] [--for <comando>]
#
# Argumentos:
#   --for requirements   Lista architecture, domain, inventory, principles
#   --for plan           Lista architecture, c4-context, state-machines, dependencies, code-analysis, principles
#   --for to-do          Lista architecture, code-analysis
#   --for audit          Lista architecture, domain
#   --for coding         Lists architecture, domain, code-analysis (to generate legacy-impact)
#   sem --for            Lista todos os arquivos presentes em _reversa_sdd/
#
# Exit codes:
#   0 = sucesso
#   1 = _reversa_sdd missing
#   2 = invalid usage

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SDD_DIR="$PROJECT_ROOT/.reversa/_reversa_sdd"

JSON_MODE=0
TARGET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON_MODE=1; shift ;;
    --for) shift; TARGET="${1:-}"; shift ;;
    *) echo "uso invalido: $1" >&2; exit 2 ;;
  esac
done

if [ ! -d "$SDD_DIR" ]; then
  echo "error: $SDD_DIR does not exist. run the reverse pipeline first." >&2
  exit 1
fi

declare -a wanted

case "$TARGET" in
  requirements) wanted=("architecture.md" "domain.md" "inventory.md") ;;
  plan)         wanted=("architecture.md" "c4-context.md" "state-machines.md" "dependencies.md" "code-analysis.md") ;;
  to-do|todo)   wanted=("architecture.md" "code-analysis.md") ;;
  audit)        wanted=("architecture.md" "domain.md") ;;
  coding)       wanted=("architecture.md" "domain.md" "code-analysis.md") ;;
  *)            wanted=("architecture.md" "c4-context.md" "code-analysis.md" "confidence-report.md" "dependencies.md" "domain.md" "inventory.md" "questions.md" "state-machines.md") ;;
esac

declare -a present
declare -a absent

for f in "${wanted[@]}"; do
  if [ -f "$SDD_DIR/$f" ]; then
    present+=("$f")
  else
    absent+=("$f")
  fi
done

emit_json() {
  printf '{'
  printf '"sdd-dir":"%s",' "$SDD_DIR"
  printf '"target":"%s",' "$TARGET"
  printf '"present":['
  local first=1
  for f in "${present[@]:-}"; do
    [ -z "$f" ] && continue
    if [ $first -eq 1 ]; then first=0; else printf ','; fi
    printf '"%s/%s"' "$SDD_DIR" "$f"
  done
  printf '],'
  printf '"absent":['
  first=1
  for f in "${absent[@]:-}"; do
    [ -z "$f" ] && continue
    if [ $first -eq 1 ]; then first=0; else printf ','; fi
    printf '"%s"' "$f"
  done
  printf ']'
  printf '}\n'
}

if [ $JSON_MODE -eq 1 ]; then
  emit_json
else
  echo "presentes:"
  for f in "${present[@]:-}"; do
    [ -n "$f" ] && echo "  $SDD_DIR/$f"
  done
  echo "ausentes:"
  for f in "${absent[@]:-}"; do
    [ -n "$f" ] && echo "  $f"
  done
fi

exit 0
