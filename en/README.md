# Isomorphic Specification Methodology (ISM) 0.8

ISM is a specification-driven methodology for human and AI-agent software development.

**Specification is primary. Code is secondary.**  
**Code is transient. Intent is permanent.**

## Model

- `ism/` stores Definition.
- A Spec makes a specific Target managed.
- Meta defines scope rules but never creates a Target.
- Projection is output and Managed Targets must be recoverable.
- `order` controls context order, not rule priority.
- Manifest has no `order` and is always displayed first.

## Structure

```text
[root]/
├── ism/
│   ├── --manifest-core.md
│   ├── --manifest-topology.md
│   ├── --manifest-workflow.md
│   ├── --manifest-adr.md
│   └── -meta-project.md
│
├── backend/
│   ├── ism/
│   │   ├── -0-meta-typescript.md
│   │   └── src/
│   │       ├── -10-spec-api.ts.md
│   │       └── -20-exact-schema.json
│   └── src/
│       ├── api.ts
│       └── schema.json
│
└── README.md
```

`backend/ism/src/-10-spec-api.ts.md` defines `backend/src/api.ts`.

A project may contain multiple `<scope>/ism/` Definition Zones. The Manifest Set exists only in `[root]/ism/` and applies project-wide.

## Specifications

```text
-[order-]meta-[name].md
-[order-]spec-[target].md
-[order-]exact-[target]
```

Semantic Spec defines required meaning. Exact Spec defines exact Target content.

## Lifecycle

- **Definition** — change Meta/Spec.
- **Synthesis** — Definition → Projection.
- **Verification** — inspect Drift without changes.
- **Reconciliation** — Projection → proposed Definition change.

## Writing Principle

Use the shortest text that preserves all required meaning. Do not restate known context.

Detailed rules are in [`ism/`](./ism/).
