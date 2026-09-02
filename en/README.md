# Isomorphic Specification Methodology (ISM) 0.9

ISM is a specification-driven methodology for human and AI-agent software development.

**Specification is primary. Code is secondary.**  
**Code is transient. Intent is permanent.**

## Model

- `ism/` stores Definition.
- Spec defines a specific Target.
- Meta defines scope rules but does not define a Target.
- Manifest defines the project's ISM protocol.
- Exact defines exact Target content.
- `order` controls file order only.

## Structure

```text
[root]/
├── ism/
│   ├── -00-manifest-core.md
│   ├── -10-manifest-topology.md
│   ├── -20-manifest-workflow.md
│   ├── -30-manifest-adr.md
│   └── -40-meta-project.md
│
├── backend/
│   ├── ism/
│   │   ├── -10-meta-typescript.md
│   │   └── src/
│   │       ├── -20-spec-api.ts.md
│   │       └── -30-exact-schema.json
│   └── src/
│       ├── api.ts
│       └── schema.json
│
└── README.md
```

`backend/ism/src/-20-spec-api.ts.md` defines `backend/src/api.ts`.

A project may contain multiple `<scope>/ism/` Definition Zones. The Manifest Set exists only in `[root]/ism/` and applies project-wide.

## File forms

```text
-[order-]manifest-[name].md
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

## Writing principle

Use the shortest text sufficient for unambiguous meaning. Do not restate known context.

Detailed rules are in [`ism/`](./ism/).
