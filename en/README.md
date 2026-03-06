# Isomorphic Specification Methodology (ISM)

**ISM** is a spec-driven software design and development methodology, architecturally optimized for symbiosis with AI agents.

The primary goal of the methodology is to shift the developer's focus from writing source code to formalizing meanings and intents. In an era where AI generates code faster than humans, the primary value is no longer the code itself, but a deterministic knowledge repository of **how** and **why** that code should work.


## Fundamental Paradigm

**«The Specification is primary. The Artifact is secondary.»**
**«Code is transient. Intent is permanent.»**

Within ISM, source code (or any other derivative product) is classified as a *transient* (disposable) artifact. This means that the complete deletion of the project's executable code does not lead to a loss of information about the system. The project can be semantically equivalently regenerated (synthesized) from scratch based on declarative specifications.


## Key Features

*   **Structural Isomorphism:** The directory containing specifications mirrors the file structure of the actual project. This ensures intuitive navigation and unambiguous context for AI agents.
*   **Principle of Selective Management:** You are not required to describe every file. ISM manages only those zones for which specifications have been created. The rest of the project (e.g., package configurations, third-party dependencies, etc.) remains outside the jurisdiction of the AI.
*   **Semantic Anchoring (ADR):** A built-in mechanism for protecting architectural decisions (the `@ADR:` tag). It prohibits AI agents from deleting or refactoring critical logic without explicit human permission.
*   **Role Separation:** The human acts as the Architect (working with meanings), and the AI agent acts as the Synthesizer (turning meanings into working code).


## Architectural Topology

An ISM-compatible project is logically divided into two strictly isolated zones.

1.  **Definition Zone (`[root]/ism/`):** The Single Source of Truth. A repository of declarative requirements, constraints, and architectural decisions.
2.  **Projection Zone (`[root]/...`):** Executable code, configurations. Generated and managed by the ISM Agent.

### Example structure of an ISM-compatible project:

```text
[root]/
├── ism/                              <-- DEFINITION ZONE (Source of Truth)
│   ├── -0-manifest-core.md           <-- Manifest (methodology axioms)
│   ├── -meta-backend.md              <-- Meta-specification (tech stack, linters, DB)
│   └── src/
│       └── auth/                     <-- Isomorphic structure (mirrors the root)
│           ├── -func-login.md        <-- Functional specification (business logic)
│           └── -impl-crypto.ts       <-- Implementation specification (immutable code)
│
├── src/                              <-- PROJECTION ZONE (Generated Code)
│   └── auth/
│       ├── login.ts                  <-- Artifact synthesized by AI based on -func-login.md
│       └── crypto.ts                 <-- Artifact synthesized by AI from -impl-crypto.ts
│
├── package.json                      <-- Unmanaged file (outside ISM jurisdiction)
└── README.md
```


## Lifecycle

The interaction between the developer and the ISM Agent is built on three basic protocols:

1.  **Synthesis (Vector: Meaning to Code):** The AI agent reads `ism/` and generates code in the working directory.
2.  **Reconciliation (Vector: Code to Meaning):** Reverse transfer. If a programmer manually fixes a bug in the code, the AI agent analyzes the changes (Drift) and proposes edits to the corresponding specifications in `ism/`. Requires human approval.
3.  **Verification:** Automatic inspection of the project for discrepancies between specifications and the actual code.


## 📚 ISM Manifests (Documentation)

The detailed formalization of the methodology is described in the Manifests located in the [📂 ism/](./ism/) directory:

*   📖 **[0. Core Axioms & Definitions](./ism/-0-manifest-core.md)** — Glossary, axioms, and jurisdiction principles.
*   🧭 **[1. Topology & Artifacts](./ism/-1-manifest-topology.md)** — Rules of structural isomorphism, naming conventions, and the 4 types of specifications.
*   ⚙️ **[2. Workflows & Protocols](./ism/-2-manifest-workflow.md)** — Priority cascade during conflicts, Synthesis and Reconciliation modes.
*   ⚓ **[3. Architectural Decision Records](./ism/-3-manifest-adr.md)** — The ADR concept, tag syntax, and protection against "Semantic Drift".

---

*[⬅️ Back to language selection](../README.md)*

