#!/usr/bin/env bash
#
# PKS Conformance Test
#
# Verifies that a project's .claude/knowledge/ directory conforms
# to the Project Knowledge Standard.
#
# Usage: ./conformance-test.sh [--target DIR] [--level core|standard|complete]
#

set -euo pipefail

TARGET_DIR="${PWD}"
LEVEL="core"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET_DIR="$2"; shift 2 ;;
    --level) LEVEL="$2"; shift 2 ;;
    --help) echo "Usage: $0 [--target DIR] [--level core|standard|complete]"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

KNOWLEDGE_DIR="${TARGET_DIR}/.claude/knowledge"
PASS=0; FAIL=0; WARN=0

check_pass() { PASS=$((PASS+1)); echo "  ✅ $*"; }
check_fail() { FAIL=$((FAIL+1)); echo "  ❌ $*"; }
check_warn() { WARN=$((WARN+1)); echo "  ⚠️  $*"; }

echo; echo "═══ PKS Conformance Test ═══"
echo "Target: ${TARGET_DIR}"; echo "Level:  ${LEVEL}"; echo

# ─── Core ──────────────────────────────────────────────────────

echo "── File Existence ──"
[ -f "${KNOWLEDGE_DIR}/INDEX.md" ]          && check_pass "INDEX.md exists"          || check_fail "INDEX.md missing"
[ -f "${KNOWLEDGE_DIR}/points.md" ]         && check_pass "points.md exists"         || check_fail "points.md missing"
[ -f "${KNOWLEDGE_DIR}/term-mapping.md" ]   && check_pass "term-mapping.md exists"   || check_fail "term-mapping.md missing"
[ -d "${KNOWLEDGE_DIR}/kbase" ]             && check_pass "kbase/ exists"            || check_fail "kbase/ missing"
[ -f "${KNOWLEDGE_DIR}/kbase/architecture.md" ] && check_pass "kbase/architecture.md exists" || check_fail "kbase/architecture.md missing"

echo; echo "── INDEX.md ──"
[ -f "${KNOWLEDGE_DIR}/INDEX.md" ] && grep -q '```' "${KNOWLEDGE_DIR}/INDEX.md" && check_pass "Directory tree present" || check_warn "No directory tree"

echo; echo "── points.md ──"
if [ -f "${KNOWLEDGE_DIR}/points.md" ]; then
  KP=$(grep -c '### KP-' "${KNOWLEDGE_DIR}/points.md" || true)
  [ "$KP" -ge 3 ] && check_pass "${KP} knowledge points (≥3)" || check_fail "Only ${KP} KPs (need ≥3)"
  grep -q '\*\*Keywords\*\*' "${KNOWLEDGE_DIR}/points.md" && check_pass "Has Keywords field" || check_fail "No Keywords"
  grep -q '\*\*Fact\*\*'     "${KNOWLEDGE_DIR}/points.md" && check_pass "Has Fact field"     || check_fail "No Fact"
fi

echo; echo "── term-mapping.md ──"
[ -f "${KNOWLEDGE_DIR}/term-mapping.md" ] && grep -qi 'Business Term' "${KNOWLEDGE_DIR}/term-mapping.md" && check_pass "Entity table present" || check_fail "No entity table"

# ─── Standard ──────────────────────────────────────────────────

if [ "$LEVEL" = "standard" ] || [ "$LEVEL" = "complete" ]; then
  echo; echo "── Standard ──"
  [ -f "${KNOWLEDGE_DIR}/kbase/api-design.md" ] && check_pass "api-design.md exists" || check_fail "api-design.md missing"
fi

# ─── Complete ──────────────────────────────────────────────────

if [ "$LEVEL" = "complete" ]; then
  echo; echo "── Complete ──"
  [ -f "${KNOWLEDGE_DIR}/kbase/database.md" ] && check_pass "database.md exists" || check_fail "database.md missing"
  [ -f "${KNOWLEDGE_DIR}/kbase/frontend.md" ] && check_pass "frontend.md exists" || check_fail "frontend.md missing"
fi

# ─── Summary ───────────────────────────────────────────────────

echo; echo "═══ Results ═══"
echo "  ✅ Pass: ${PASS}  ❌ Fail: ${FAIL}  ⚠️  Warn: ${WARN}"
[ "$FAIL" -gt 0 ] && echo "❌ FAILED"   && exit 1
[ "$WARN" -gt 0 ] && echo "⚠️  PASSED with warnings" && exit 0
echo "✅ PASSED" && exit 0
