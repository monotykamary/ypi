# Experiment: Does Tree-Awareness Help Sub-Agents?

## Hypothesis

Sub-agents that know their position in the recursion tree (depth, sibling
count, parent's goal, what other chunks cover) will produce better answers
than sub-agents that only see their chunk + a question.

## Design

**Task:** Extract specific facts from a multi-section document that requires
chunking. The document is deliberately too large for one context window, so
the parent must split it across multiple sub-agents and combine results.

**Conditions:**

| Condition | What the sub-agent sees |
|-----------|------------------------|
| A: Blind (baseline) | Just the chunk + question |
| B: Position-aware | Chunk + "You are chunk 3 of 5, lines 200-300" |
| C: Goal-aware | Chunk + parent's overall goal + what other chunks cover |
| D: Full tree | Chunk + position + goal + sibling info + depth |

**Metrics:**
- **Recall** — did it find all facts in its chunk?
- **Precision** — did it hallucinate facts not in its chunk?
- **Format compliance** — did it follow the output format?
- **Redundancy** — did it repeat information unnecessarily?

**Controls:**
- Same document, same chunks, same model, same temperature
- Multiple runs per condition (LLM non-determinism)
- Automated scoring via judge LLM

## How to run

```bash
bash experiments/tree-awareness/run.sh
```

Results go to `experiments/tree-awareness/results/`.
