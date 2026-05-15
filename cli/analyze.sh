#!/usr/bin/env bash
#
# project-knowledge CLI — analyze.sh
#
# Lightweight CLI implementation of the Project Knowledge Standard.
# Scans a project directory and generates PKS-conformant knowledge files.
#
# Usage:
#   ./analyze.sh [--target DIR] [--lang en|zh-CN] [--dry-run]
#
# No LLM dependency. Structural analysis only.
# For full intelligence (entity extraction, pattern analysis), use skill.md.
#

set -euo pipefail

TARGET_DIR="${PWD}"
OUTPUT_DIR=".claude/knowledge"
LANG="en"
DRY_RUN=false
TEMPLATE_DIR="$(cd "$(dirname "$0")/../templates" && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET_DIR="$2"; shift 2 ;;
    --lang) LANG="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help) echo "Usage: $0 [--target DIR] [--lang en|zh-CN] [--dry-run]"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

info()  { echo "ℹ️  $*"; }
ok()    { echo "✅ $*"; }
warn()  { echo "⚠️  $*"; }
error() { echo "❌ $*" >&2; }

# ─── Step 0: Security ──────────────────────────────────────────

info "Security check: ${TARGET_DIR}"
[ ! -d "$TARGET_DIR" ] && error "Not a directory: ${TARGET_DIR}" && exit 1

BLOCKED_PATTERNS=(
  ".env" ".env.*" "credentials*" "*.pem" "*.key"
  "*.exe" "*.dll" "*.so" "*.dylib"
  "*.jpg" "*.jpeg" "*.png" "*.gif"
  "*.zip" "*.tar" "*.gz" "*.rar"
  "node_modules" ".git" "dist" "build" ".next" ".cache" "vendor"
)

# ─── Step 1: Classification ────────────────────────────────────

PROJECT_NAME="$(basename "$TARGET_DIR")"
PROJECT_TYPE="general"

if [ -f "${TARGET_DIR}/package.json" ]; then
  NAME=$(node -e "try{console.log(require('${TARGET_DIR}/package.json').name||'');}catch(e){}" 2>/dev/null || true)
  [ -n "$NAME" ] && PROJECT_NAME="$NAME"
  grep -q '"next"' "${TARGET_DIR}/package.json" 2>/dev/null && PROJECT_TYPE="web-fullstack"
  grep -q '"react"' "${TARGET_DIR}/package.json" 2>/dev/null && [ "$PROJECT_TYPE" = "general" ] && PROJECT_TYPE="spa-frontend"
elif [ -f "${TARGET_DIR}/go.mod" ]; then
  PROJECT_TYPE="backend-api"
elif [ -f "${TARGET_DIR}/Cargo.toml" ]; then
  PROJECT_TYPE="cli-tool"
elif [ -f "${TARGET_DIR}/pyproject.toml" ] || [ -f "${TARGET_DIR}/requirements.txt" ]; then
  PROJECT_TYPE="data-ml"
fi
ok "Project: ${PROJECT_NAME} (${PROJECT_TYPE})"

# ─── Step 2: Scale ─────────────────────────────────────────────

TOTAL_FILES=$(find "$TARGET_DIR" -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/.next/*' -not -path '*/vendor/*' -type f 2>/dev/null | wc -l | tr -d ' ')
SOURCE_FILES=$(find "$TARGET_DIR" -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/.next/*' -not -path '*/vendor/*' \( -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.py' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.md' \) 2>/dev/null | wc -l | tr -d ' ')

if [ "$TOTAL_FILES" -lt 50 ]; then SCALE="small"
elif [ "$TOTAL_FILES" -lt 200 ]; then SCALE="medium"
elif [ "$TOTAL_FILES" -lt 1000 ]; then SCALE="large"
else SCALE="xlarge"
fi
ok "${TOTAL_FILES} total files, ${SOURCE_FILES} source — ${SCALE}"

# ─── Step 3: Directory Tree ────────────────────────────────────

MAX_DEPTH=2; [ "$SCALE" = "small" ] && MAX_DEPTH=4; [ "$SCALE" = "medium" ] && MAX_DEPTH=3
DIR_TREE=$(find "$TARGET_DIR" -maxdepth "$MAX_DEPTH" -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/.next/*' -not -path '*/vendor/*' -type d 2>/dev/null | sed "s|${TARGET_DIR}/||" | sort | head -80)

# ─── Step 4: Generate ──────────────────────────────────────────

OUTPUT_PATH="${TARGET_DIR}/${OUTPUT_DIR}"

if [ "$DRY_RUN" = true ]; then
  echo; echo "═══ Dry Run: ${OUTPUT_PATH} ═══"; echo
  echo "Project: ${PROJECT_NAME} | Type: ${PROJECT_TYPE} | Scale: ${SCALE}"
  echo; echo "Structure:"; echo "${DIR_TREE}"
  echo; echo "Files:"; echo "  INDEX.md, points.md, term-mapping.md, kbase/architecture.md"
  exit 0
fi

mkdir -p "${OUTPUT_PATH}/kbase"
TEMPLATE_LANG_DIR="${TEMPLATE_DIR}"; [ -d "${TEMPLATE_DIR}/${LANG}" ] && TEMPLATE_LANG_DIR="${TEMPLATE_DIR}/${LANG}"

DATE=$(date +%Y-%m-%d)
for tmpl in INDEX.md.tmpl points.md.tmpl term-mapping.md.tmpl; do
  sed -e "s/{Project Name}/${PROJECT_NAME}/g" -e "s/{generation-date}/${DATE}/g" "${TEMPLATE_LANG_DIR}/${tmpl}" > "${OUTPUT_PATH}/${tmpl%.tmpl}"
  ok "Generated ${tmpl%.tmpl}"
done

# architecture.md with directory tree injected
sed -e "s/{Project Name}/${PROJECT_NAME}/g" -e "s/{generation-date}/${DATE}/g" -e "/{project directory tree}/{r /dev/stdin" -e "d}" <<< "${DIR_TREE}" "${TEMPLATE_LANG_DIR}/kbase/architecture.md.tmpl" > "${OUTPUT_PATH}/kbase/architecture.md"
ok "Generated kbase/architecture.md"

case "$PROJECT_TYPE" in
  web-fullstack|spa-frontend)
    for tmpl in api-design.md.tmpl frontend.md.tmpl; do
      sed -e "s/{Project Name}/${PROJECT_NAME}/g" -e "s/{generation-date}/${DATE}/g" "${TEMPLATE_LANG_DIR}/kbase/${tmpl}" > "${OUTPUT_PATH}/kbase/${tmpl%.tmpl}"
      ok "Generated kbase/${tmpl%.tmpl}"
    done ;;
  backend-api)
    for tmpl in api-design.md.tmpl database.md.tmpl; do
      sed -e "s/{Project Name}/${PROJECT_NAME}/g" -e "s/{generation-date}/${DATE}/g" "${TEMPLATE_LANG_DIR}/kbase/${tmpl}" > "${OUTPUT_PATH}/kbase/${tmpl%.tmpl}"
      ok "Generated kbase/${tmpl%.tmpl}"
    done ;;
esac

echo; echo "═══ Done ═══"
echo "Output: ${OUTPUT_PATH}/"
warn "Placeholders ({...}) remain — run skill.md for full intelligence."
