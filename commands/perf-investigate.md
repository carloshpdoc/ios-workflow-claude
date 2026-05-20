# Perf / Leak Investigation

Drive an iOS performance or memory-leak investigation on {{APP}} using Memory Graph + Time Profiler. Enforce data-before-architecture and stacked PRs.

## Usage

```
/perf-investigate <symptom or {{TICKET_PREFIX}}-XXXX>
```

**Examples:**
```
/perf-investigate <Feature> place-details opens are slow after 15 cycles
/perf-investigate {{TICKET_PREFIX}}-XXXX
/perf-investigate Explore tab leaks BSPlaceDetailVMV3
```

## Triggers

Run this skill when the user mentions any of: "perf", "lento", "slow", "leak", "memory", "vazamento", "TTI", "hang", "jank", "frame drop", "spin", "freezou", "trava".

## Hard rules (do not skip)

1. **No architectural change before measurement.** Reject hypotheses framed in architectural terms ("the wrapper is wrong", "the navigation pattern leaks") until the user provides a `.memgraph` (for retention) or a `.trace` (for TTI/jank).
2. **Memory Graph (`.memgraph`) for retain cycles, NOT `xctrace --template Leaks --attach`.** The latter fails silently with `libmalloc not initialized`. See `reference_ios_leak_tooling.md`.
3. **Time Profiler with `--attach` works** for hangs and CPU sampling. Use it for TTI/slowness investigations.
4. **Compare to a fluid baseline tab.** Pick a known-fluid feature in your app as the baseline; capture both the suspect and baseline in the same session.
5. **One PR per logical fix.** If the investigation produces 2+ fixes, use stacked PRs — see `commit-and-pr` skill.

## Workflow

### Phase 1 — Triage (no code yet)

1. Restate the symptom in observable terms (e.g., "after 15 opens, next open takes 6s" not "the wishlist is slow").
2. Decide the right tool:
   - "X is retained / leaking / accumulating" → Memory Graph (Tool 2 in the tooling memory).
   - "X is slow / hangs / janky" → Time Profiler (Tool 3 in the tooling memory).
   - "Memory grows over time without leaks" → Allocations Mark-Heap (Instruments GUI only — fall back to user).
3. Ask the user to capture the right artifact and save to `~/Desktop/<descriptive-name>.{memgraph,trace}`. Provide the exact `xctrace` command if Time Profiler is needed.
4. Also ask for a baseline capture from a comparable fluid tab (usually Explore) when relevant.

### Phase 2 — Analysis (CLI only, no GUI)

For Memory Graph (`.memgraph`):
```bash
leaks ~/Desktop/X.memgraph 2>&1 | grep -E "ROOT CYCLE|<TargetClass>" | head -40
heap ~/Desktop/X.memgraph 2>&1 | grep -E "BSPlaceDetailVMV3|<class names>"
```

For Time Profiler (`.trace`):
```bash
xcrun xctrace export --input ~/Desktop/X.trace \
  --xpath '/trace-toc/run/data/table[@schema="potential-hangs"]' \
  > /tmp/hangs.xml
xcrun xctrace export --input ~/Desktop/X.trace \
  --xpath '/trace-toc/run/data/table[@schema="time-profile"]' \
  > /tmp/time-profile.xml
```

Use the Python parser pattern at `/tmp/tti-analysis/analyze3.py` (or write a fresh one) to:
- Filter to Main Thread samples
- Group by binary, then by inclusive frame in the `{{APP}}` binary
- Print top-20 hot frames

### Phase 3 — Identify root cause

Look for these patterns first (based on past iOS investigations):

| Pattern | Hint |
|---|---|
| `*Context.make` factory NOT in `PlaceActionsViewModelCache.shared.getOrCreateViewModel(...)` while siblings use it | Compare line numbers in `PlaceActionsFactory.swift`: 205 (<FeatureA>), 297 (<FeatureB>), 473 (<FeatureC>), 554 (<FeatureD>). The outlier feature was tracked as {{TICKET_PREFIX}}-XXXX. |
| `CTTelephonyNetworkInfo.__allocating_init` in top-N inclusive | Per-instance NetworkConnectivityChecker. Use `NetworkConnectivityChecker.shared` ({{TICKET_PREFIX}}-XXXX). |
| ROOT CYCLE through `TagIndexProjection<Int>` in a SwiftUI carousel | `.tag()` on ForEach items, closures capturing `self`. Convert closures to `static func` + `[weak]` ({{TICKET_PREFIX}}-XXXX). |
| ROOT CYCLE involving `_ContiguousArrayStorage<Optional<...Coordinator...>>` or `SwiftUI.StoredLocation<Coordinator>` | `@State` reference type leaked via closure capturing `_state` wrapper. Use `[weak coord = self.coordinator]` not `[coordState = _coordinator]`. |
| Cycle involving `UINavigationController.viewControllers ↔ host VC ↔ @State coordinator` | UIViewControllerRepresentable with fresh nav. Add `dismantleUIViewController` clearing `viewControllers`. |

If none match, document the new pattern at the end of this skill so future runs benefit.

### Phase 4 — Fix and validate

1. Apply the smallest possible fix targeting only the proven cycle/hot-frame.
2. Build via `xcodebuild -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' build`.
3. Ask user to capture a fresh `.memgraph` / `.trace` after reproducing the same flow.
4. Re-run Phase 2 analysis. Compare to baseline.
5. Goal: target hot frame drops by ≥50% OR retain count drops to 0.

### Phase 5 — Output

Produce a comparison table for the PR description and the Jira comment using this template:

```markdown
| Metric | BEFORE | AFTER | Baseline (Explore) |
|---|---|---|---|
| Hangs >250ms | N | M | E |
| Total hang time | Ns | Ms | Es |
| `<HotFrame>` inclusive | N% | M% | E% |
```

Then:
- Open PR via `create-pr-from-staged-changes` skill, base `dev` (or stack on parent).
- Update Jira via `update-jira` skill with the validation table embedded as a comment.
- If the fix took fewer steps than originally sized, reduce the SP count on the ticket.

## Anti-patterns (block these)

- **Wholesale `[weak self]` refactor across SwiftUI body.** Capturing `_state` / `_observed` property wrappers can paradoxically retain backing storage in escaped closures. Only weak-capture the closure proven by the memgraph to be the cycle root.
- **Migrating presentation pattern (`fullScreenCover` ↔ `sheet` ↔ `bottomSheet`) without Time Profiler evidence that presentation is the bottleneck.** {{TICKET_PREFIX}}-XXXX wasted hours on a `.sheet` swap before the profiler showed the cause was a missing cache.
- **Sizing the Jira at the size of the original plan.** Re-size DOWN once Time Profiler points at a smaller fix. The cache fix in {{TICKET_PREFIX}}-XXXX was sized 8 SP, delivered as 3.

## When to escalate vs continue

- If the hot frame is in a third-party SDK or system framework → stop, report, do not refactor app code to "work around" without measurement.
- If the user pushes for "let's just try changing X" → push back: ask for the trace data first.
- If you find a fix path that touches 5+ unrelated files → stop, propose splitting into stacked PRs.

## References

- `reference_ios_leak_tooling.md` — tool capabilities and caveats
- Past investigations: {{TICKET_PREFIX}}-XXXX (leak), {{TICKET_PREFIX}}-XXXX (cache), {{TICKET_PREFIX}}-XXXX (singleton)
