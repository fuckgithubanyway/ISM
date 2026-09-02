# ISM Manifest: Workflow

**Version:** 0.9  
**Status:** Translation of the canonical Russian normative text

## Target Context

ISM-Agent resolves Target context from:

1. Manifest Set;
2. applicable Meta Sets, from general scope to specific scope;
3. Target Spec Set.

Canonical file order controls reading and display, not semantic context resolution.

More-specific Meta may override less-specific Meta. Any other incompatible normative requirement is a **Collision**.

`order` never resolves Collision. ISM-Agent never resolves Collision by guessing.

A Collision blocks only the affected operation. A Manifest Set Collision blocks project ISM operations.

User is not a rule level. An explicit User request to change Definition approves the changes required by that request.

## Operations

Each operation has one mode. One User request may execute several modes sequentially.

### Definition

Changes only Meta and Spec. Manifest is not changed.

Used to change rules, intent, and Targets.

### Synthesis

Direction: `Definition → Projection`.

ISM-Agent:

1. resolves context;
2. detects Collision;
3. computes the minimum required Target changes;
4. applies them;
5. performs Verification.

Synthesis never changes Definition or unmanaged files and does not change an already conforming Target without need.

On Collision, affected changes are not applied. Synthesis must not intentionally leave a partial state; if the environment prevents restoration, this is reported explicitly to User.

### Verification

Changes nothing.

Drift exists only for Targets:

- **Missing** — a required Target is absent;
- **Unexpected** — an `@ABSENT` Target exists;
- **Exact** — Target differs from Exact Spec;
- **Semantic** — Target contradicts Semantic Spec;
- **Policy** — Target violates applicable Meta.

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

A Semantic Spec containing `@ABSENT` requires Target absence and contains no other normative requirements.

Preferred form:

```text
@ABSENT
```

or, when a reason is needed:

```text
@ABSENT: <reason>
```

`@ABSENT` remains while Target absence remains a requirement.

Rename/Move is expressed as `@ABSENT` for the old Target and a Spec for the new Target.
