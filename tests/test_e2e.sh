#!/bin/bash
# test_e2e.sh — End-to-end tests with REAL LLM calls
#
# These tests hit actual LLM APIs and cost money. Run sparingly.
# They verify the full recursive chain works, not just the bash plumbing.
#
# Prerequisites:
#   - pi installed and on PATH
#   - CEREBRAS_API_KEY or OPENROUTER_API_KEY set
#   - ~$0.01-0.05 per full run
#
# Run: bash tests/test_e2e.sh
# Run single: bash tests/test_e2e.sh E1
# Skip slow: RLM_SKIP_SLOW=1 bash tests/test_e2e.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

export PATH="$PROJECT_DIR:$PATH"
export RLM_SYSTEM_PROMPT="$PROJECT_DIR/SYSTEM_PROMPT.md"

# Default provider/model — override with env vars
export RLM_PROVIDER="${RLM_PROVIDER:-cerebras}"
export RLM_MODEL="${RLM_MODEL:-qwen-3-32b}"
export RLM_MAX_DEPTH="${RLM_MAX_DEPTH:-3}"

PASS=0
FAIL=0
SKIP=0
ERRORS=""
FILTER="${1:-}"  # Optional: run only test matching this prefix

pass() { PASS=$((PASS + 1)); echo "  ✓ $1 (${2:-}s)"; }
fail() { FAIL=$((FAIL + 1)); ERRORS="${ERRORS}\n  ✗ $1: $2"; echo "  ✗ $1: $2"; }
skip() { SKIP=$((SKIP + 1)); echo "  ⊘ $1 (skipped: $2)"; }

should_run() {
    [ -z "$FILTER" ] || [[ "$1" == "$FILTER"* ]]
}

# Temp dir for test artifacts
TEST_TMP=$(mktemp -d /tmp/rlm_e2e_XXXXXX)
export PI_TRACE_FILE="$TEST_TMP/trace.log"
trap 'rm -rf "$TEST_TMP"' EXIT

echo ""
echo "=== E2E Tests (provider=$RLM_PROVIDER model=$RLM_MODEL) ==="
echo "    Trace: $PI_TRACE_FILE"
echo ""

# ─── E1: Simple QA — no recursion needed ─────────────────────────────────

if should_run "E1"; then
    echo "--- E1: Simple QA (small context, direct answer) ---"
    cat > "$TEST_TMP/ctx_e1.txt" << 'EOF'
=== User Profile ===
Name: Alice Johnson
University: MIT
Graduation Year: 2019
Degree: Computer Science
EOF
    export CONTEXT="$TEST_TMP/ctx_e1.txt"
    export RLM_DEPTH=0

    START=$(date +%s)
    OUTPUT=$(rlm_query "What university did the user graduate from? Reply with ONLY the university name." 2>/dev/null || echo "ERROR")
    ELAPSED=$(( $(date +%s) - START ))

    if echo "$OUTPUT" | grep -qi "MIT"; then
        pass "E1: simple QA" "$ELAPSED"
    else
        fail "E1: simple QA" "expected 'MIT' in output, got: $(echo "$OUTPUT" | head -3)"
    fi
fi

# ─── E2: Piped context — chunk becomes child context ─────────────────────

if should_run "E2"; then
    echo "--- E2: Piped context ---"
    export RLM_DEPTH=0

    START=$(date +%s)
    OUTPUT=$(echo "The user's favorite programming language is Rust." | \
        rlm_query "What programming language? Reply with ONLY the language name." 2>/dev/null || echo "ERROR")
    ELAPSED=$(( $(date +%s) - START ))

    if echo "$OUTPUT" | grep -qi "Rust"; then
        pass "E2: piped context" "$ELAPSED"
    else
        fail "E2: piped context" "expected 'Rust', got: $(echo "$OUTPUT" | head -3)"
    fi
fi

# ─── E3: Leaf node — depth at max, no tools ──────────────────────────────

if should_run "E3"; then
    echo "--- E3: Leaf node (at max depth, no tools) ---"
    cat > "$TEST_TMP/ctx_e3.txt" << 'EOF'
The capital of France is Paris.
EOF
    export CONTEXT="$TEST_TMP/ctx_e3.txt"
    export RLM_DEPTH=2
    export RLM_MAX_DEPTH=3

    START=$(date +%s)
    OUTPUT=$(rlm_query "What is the capital of France? Reply with ONLY the city name." 2>/dev/null || echo "ERROR")
    ELAPSED=$(( $(date +%s) - START ))

    if echo "$OUTPUT" | grep -qi "Paris"; then
        pass "E3: leaf node" "$ELAPSED"
    else
        fail "E3: leaf node" "expected 'Paris', got: $(echo "$OUTPUT" | head -3)"
    fi

    # Reset
    export RLM_DEPTH=0
    export RLM_MAX_DEPTH=3
fi

# ─── E4: Recursion — model spawns sub-call via rlm_query ─────────────────

if should_run "E4"; then
    if [ "${RLM_SKIP_SLOW:-}" = "1" ]; then
        skip "E4: recursive sub-call" "RLM_SKIP_SLOW=1"
    else
        echo "--- E4: Recursive sub-call (depth 0→1) ---"
        cat > "$TEST_TMP/ctx_e4.txt" << 'EOF'
=== Session 1 (2024-01-15) ===
User said: "I just got back from Tokyo. The cherry blossoms were beautiful."

=== Session 2 (2024-02-20) ===  
User said: "My trip to Tokyo was the highlight of my year."

=== Session 3 (2024-03-10) ===
User said: "I'm planning another trip, maybe to Kyoto this time."
EOF
        export CONTEXT="$TEST_TMP/ctx_e4.txt"
        export RLM_DEPTH=0

        START=$(date +%s)
        OUTPUT=$(rlm_query "What city did the user visit? Reply with ONLY the city name." 2>/dev/null || echo "ERROR")
        ELAPSED=$(( $(date +%s) - START ))

        if echo "$OUTPUT" | grep -qi "Tokyo"; then
            pass "E4: recursive sub-call" "$ELAPSED"
        else
            fail "E4: recursive sub-call" "expected 'Tokyo', got: $(echo "$OUTPUT" | head -3)"
        fi

        # Verify trace shows depth transition
        if [ -f "$PI_TRACE_FILE" ]; then
            if grep -q "depth=0→1" "$PI_TRACE_FILE"; then
                pass "E4: trace shows depth transition" "$ELAPSED"
            else
                fail "E4: trace shows depth transition" "no depth=0→1 in trace"
            fi
        fi
    fi
fi

# ─── E5: Timeout enforcement (if implemented) ────────────────────────────

if should_run "E5"; then
    if grep -q "RLM_TIMEOUT" "$PROJECT_DIR/rlm_query" 2>/dev/null; then
        echo "--- E5: Timeout enforcement ---"
        cat > "$TEST_TMP/ctx_e5.txt" << 'EOF'
Write a 10,000 word essay about the history of mathematics.
Include every mathematician ever.
EOF
        export CONTEXT="$TEST_TMP/ctx_e5.txt"
        export RLM_DEPTH=0
        export RLM_TIMEOUT=5  # 5 second timeout — should be too short

        START=$(date +%s)
        OUTPUT=$(rlm_query "Write the full essay as requested." 2>&1 || true)
        ELAPSED=$(( $(date +%s) - START ))

        if [ "$ELAPSED" -lt 15 ]; then
            pass "E5: timeout killed long task" "$ELAPSED"
        else
            fail "E5: timeout" "took ${ELAPSED}s, expected < 15s"
        fi

        unset RLM_TIMEOUT
    else
        skip "E5: timeout enforcement" "RLM_TIMEOUT not implemented yet"
    fi
fi

# ─── E6: Max calls enforcement (if implemented) ──────────────────────────

if should_run "E6"; then
    if grep -q "RLM_MAX_CALLS" "$PROJECT_DIR/rlm_query" 2>/dev/null; then
        echo "--- E6: Max calls enforcement ---"
        export CONTEXT="$TEST_TMP/ctx_e4.txt"
        export RLM_DEPTH=0
        export RLM_CALL_COUNT=99
        export RLM_MAX_CALLS=100

        START=$(date +%s)
        OUTPUT=$(rlm_query "This should be blocked." 2>&1 || true)
        ELAPSED=$(( $(date +%s) - START ))

        if echo "$OUTPUT" | grep -qi "max.*call\|exceeded\|limit"; then
            pass "E6: max calls blocks" "$ELAPSED"
        else
            fail "E6: max calls" "expected error about max calls, got: $(echo "$OUTPUT" | head -3)"
        fi

        unset RLM_CALL_COUNT RLM_MAX_CALLS
    else
        skip "E6: max calls enforcement" "RLM_MAX_CALLS not implemented yet"
    fi
fi

# ─── Summary ──────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed, $SKIP skipped"
echo "═══════════════════════════════════════════════════"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Failures:"
    echo -e "$ERRORS"
    echo ""
fi

if [ -f "$PI_TRACE_FILE" ]; then
    echo ""
    echo "Trace log:"
    cat "$PI_TRACE_FILE"
fi

echo ""
[ "$FAIL" -eq 0 ] && echo "All tests passed! ✓" || exit 1
