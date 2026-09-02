# ISM Manifest: ADR

**Version:** 0.9  
**Status:** Translation of the canonical Russian normative text

## Purpose

ADR records the reason for a non-obvious decision and protects that decision from implicit change.

Format:

```text
@ADR: <decision>; <reason>
```

ADR must explicitly state both decision and reason. If the reason is obvious, ADR is unnecessary.

## Scope

ADR is recognized only in Manifest, Meta, and Semantic Spec.

Exact Spec content is opaque to ISM. `@ADR` inside Exact Spec or Projection is ordinary content with no normative authority.

ADR protects only the decision stated in the directive itself. Adjacent text is not implicitly protected.

## Rules

- ADR does not change rule force or scope and does not resolve Collision.
- ADR cannot legitimize a Definition contradiction.
- ISM-Agent preserves a protected decision until User explicitly requests its change or approves a proposal that names the change.
- ISM-Agent does not remove or modify ADR automatically.
- Reconciliation does not treat ADR as obsolete merely because Projection differs; the conflict must be shown explicitly in the proposal.

Place ADR as close as possible to its decision context and keep it minimal.
