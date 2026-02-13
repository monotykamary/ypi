#!/bin/bash
# Experiment: Does tree-awareness help sub-agents?
#
# Runs the same chunked QA task under 4 conditions (A-D) and scores results.
# Uses rlm_query directly — dogfooding the system we're testing.
#
# Usage: bash experiments/tree-awareness/run.sh
#        bash experiments/tree-awareness/run.sh --condition B --runs 3

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"

export PATH="$PROJECT_DIR:$PATH"
export RLM_SYSTEM_PROMPT="$PROJECT_DIR/SYSTEM_PROMPT.md"
export RLM_DEPTH=0
export RLM_MAX_DEPTH=3

# ─── Config ───────────────────────────────────────────────────────────────

RUNS="${RUNS:-3}"
CONDITIONS="${CONDITIONS:-A B C D}"
FILTER_CONDITION=""

while [[ "${1:-}" == --* ]]; do
    case "$1" in
        --condition) FILTER_CONDITION="$2"; shift 2 ;;
        --runs) RUNS="$2"; shift 2 ;;
        *) echo "Unknown flag: $1"; exit 1 ;;
    esac
done

if [ -n "$FILTER_CONDITION" ]; then
    CONDITIONS="$FILTER_CONDITION"
fi

mkdir -p "$RESULTS_DIR"

# ─── Test Document ────────────────────────────────────────────────────────
# A synthetic "company handbook" with facts scattered across sections.
# Ground truth is known, so we can score automatically.

DOC="$SCRIPT_DIR/test_document.txt"
if [ ! -f "$DOC" ]; then
    echo "Generating test document..."
    bash "$SCRIPT_DIR/gen_document.sh" > "$DOC"
fi

TOTAL_LINES=$(wc -l < "$DOC")
echo "Document: $DOC ($TOTAL_LINES lines)"

# ─── Chunking ─────────────────────────────────────────────────────────────
# Split into 5 roughly equal chunks (simulating what a parent agent would do)

CHUNK_SIZE=$(( (TOTAL_LINES + 4) / 5 ))
NUM_CHUNKS=5

QUESTION="Extract ALL people mentioned in this text. For each person, return their name, role, and one key fact about them. Return as a numbered list. If no people are mentioned in this section, say NONE."

# ─── Prompt Templates ─────────────────────────────────────────────────────

prompt_A() {
    # Blind — just the question
    echo "$QUESTION"
}

prompt_B() {
    local chunk_num=$1 total=$2 start_line=$3 end_line=$4
    # Position-aware
    echo "You are processing chunk $chunk_num of $total (lines $start_line-$end_line). $QUESTION"
}

prompt_C() {
    local chunk_num=$1 total=$2 start_line=$3 end_line=$4
    # Goal-aware — knows the parent's overall mission
    cat <<EOF
PARENT GOAL: Build a complete directory of all people mentioned in a ${TOTAL_LINES}-line company handbook.
YOUR CHUNK: $chunk_num of $total (lines $start_line-$end_line).
OTHER CHUNKS: The other $((total - 1)) chunks cover the remaining sections. Another agent will combine all results.
TASK: $QUESTION
EOF
}

prompt_D() {
    local chunk_num=$1 total=$2 start_line=$3 end_line=$4
    # Full tree — position + goal + depth + sibling info
    cat <<EOF
TREE POSITION:
  Depth: 1 of 3 (you are a sub-agent, spawned by a depth-0 parent)
  Call: $chunk_num of $total siblings running in parallel
  Trace: experiment-run
PARENT GOAL: Build a complete directory of all people mentioned in a ${TOTAL_LINES}-line company handbook.
YOUR CHUNK: lines $start_line-$end_line (chunk $chunk_num of $total).
SIBLINGS: Chunks 1-$total are being processed by identical agents. Each covers ~$CHUNK_SIZE lines. The parent will combine and deduplicate all results.
TASK: $QUESTION
Do NOT speculate about content in other chunks. Only report what you see in YOUR text.
EOF
}

# ─── Run Experiment ───────────────────────────────────────────────────────

echo ""
echo "=== Tree-Awareness Experiment ==="
echo "    Conditions: $CONDITIONS"
echo "    Runs per condition: $RUNS"
echo "    Chunks per run: $NUM_CHUNKS"
echo ""

for COND in $CONDITIONS; do
    echo "--- Condition $COND ---"
    
    for RUN in $(seq 1 "$RUNS"); do
        RUN_DIR="$RESULTS_DIR/${COND}_run${RUN}"
        mkdir -p "$RUN_DIR"
        
        echo "  Run $RUN/$RUNS..."
        
        for CHUNK_NUM in $(seq 1 "$NUM_CHUNKS"); do
            START_LINE=$(( (CHUNK_NUM - 1) * CHUNK_SIZE + 1 ))
            END_LINE=$(( CHUNK_NUM * CHUNK_SIZE ))
            [ "$END_LINE" -gt "$TOTAL_LINES" ] && END_LINE="$TOTAL_LINES"
            
            # Build the prompt for this condition
            PROMPT=$(prompt_${COND} "$CHUNK_NUM" "$NUM_CHUNKS" "$START_LINE" "$END_LINE")
            
            # Run the sub-agent (piping the chunk, just like a real parent would)
            OUTPUT=$(sed -n "${START_LINE},${END_LINE}p" "$DOC" | \
                     rlm_query "$PROMPT" 2>/dev/null || echo "ERROR")
            
            # Save result
            echo "$OUTPUT" > "$RUN_DIR/chunk_${CHUNK_NUM}.txt"
        done
        
        # Combine all chunks for this run (simulating what parent does)
        cat "$RUN_DIR"/chunk_*.txt > "$RUN_DIR/combined.txt"
    done
done

echo ""
echo "=== Results saved to $RESULTS_DIR ==="
echo ""
echo "Score with:"
echo "  bash experiments/tree-awareness/score.sh"
