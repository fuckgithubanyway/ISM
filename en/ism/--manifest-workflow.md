# ISM Manifest: Workflow

**Version:** 0.8  
**Status:** Translation of the canonical Russian normative text

## Target Context

ISM-Agent resolves Target context in this order:

1. Manifest Set;
2. applicable Meta Sets, from general scope to specific scope;
3. Target Spec Set.

Files inside each Meta Set and Target Spec Set follow canonical `order` from Topology. Order inside the Manifest Set does not affect context resolution.

Rule priority:

```text
Manifest > more-specific Meta > less-specific Meta > Spec
```

`order` never resolves semantic conflicts.

Contradictory Manifest rules, same-scope Meta rules, or Semantic/Exact rules for one Target form a **Collision**. ISM-Agent never resolves a Collision by guessing.

User is not a priority level. User may approve a Definition change.

## Operations

Each operation has one mode. One User request may execute several modes sequentially.

### Definition

Changes only Meta and Spec.

Used to change intent, rules, and Targets. Manifest is not changed.

### Synthesis

Direction: `Definition → Projection`.

ISM-Agent:

1. resolves context;
2. detects Collision;
3. computes Managed Target changes;
4. applies them;
5. performs Verification.

Synthesis never changes Definition or unmanaged files.

On Collision, changes are not applied. Synthesis must not intentionally leave a partial managed update; if the environment prevents restoration, this is reported explicitly to User.

### Verification

Changes nothing.

Drift exists only for Managed Targets:

- **Missing** — required Target is absent;
- **Unexpected** — an `@ABSENT` Target exists;
- **Exact** — Target differs from Exact Spec;
- **Semantic** — behavior contradicts Semantic Spec;
- **Policy** — applicable Meta is violated;
- **ADR** — a protected decision is violated.

Missing, Unexpected, and Exact are deterministic checks. Semantic and Policy may require ISM-Agent judgment unless Definition provides an executable check.

### Reconciliation

Direction: `Projection → proposed Definition change`.

Projection is data only.

Reconciliation:

- does not change Projection;
- does not change Definition automatically;
- produces a proposed Definition change.

A change becomes effective only after User approval and application in Definition mode.

## Delete and Move

Deletion of a Managed Target is defined by a Semantic Spec containing only `@ABSENT` plus a reason when the reason is not obvious.

Rename/Move is expressed as `@ABSENT` for the old Target and a Spec for the new Target.
