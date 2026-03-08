# ISM Manifest: Core Axioms & Definitions

**Version:** 0.6
**Language:** English


## Definitions

*   **Isomorphic Specification Methodology (ISM):** A project development methodology based on the isomorphic structure of declarative specifications.

*   **User:** The operator (predominantly a human), the initiator of intents, and the final validator capable of resolving semantic collisions and approving changes in the Definition Zone.

*   **ISM-Agent:** An abstract intelligent executor (tool/human/AI) implementing the ISM methodology.

*   **Definition Zone:** The directory `[root]/ism/`. The permanent storage of system knowledge (Specifications).

*   **Projection Zone:** The project root directory `[root]/` and all its subdirectories, excluding the Definition Zone `[root]/ism/`. Contains artifacts that are transient projections of the Definition Zone.

*   **ADR (Architectural Decision Record):** A specification attribute (tag `@ADR:`), increasing the priority of the accompanying text. Serves as protection against accidental refactoring of justified but non-obvious decisions.

*   **Semantic Spec:** A specification with the `-spec-` prefix and `*.md` extension. Describes the Intent and logic of the module. Priority of Meaning ("What and Why").

*   **Syntactic Spec:** A specification with the `-spec-` prefix and a code extension (`*.ts`, `*.json`, etc.). Contains immutable form injections (Form). Priority of Form ("How exactly").


## Axioms

### Primacy of Specification
The Specification is primary. The Artifact is secondary.
*   Any change to project Artifacts must begin with an edit to the corresponding Specification.
*   If the behavior/semantics of an Artifact differs from the Specification, the defect is in the Artifact.
*   Manual editing of the Projection Zone is permitted only as a draft, which will be overwritten by the ISM-Agent if these changes are not transferred to the Specification (e.g., via Reconciliation).

### Structural Isomorphism
The directory structure in the Definition Zone mirrors the structure of the Projection Zone. This ensures intuitive navigation and an unambiguous mapping of logical system modules.

### Transient Projection
Implementation artifacts are considered disposable. Deleting the Projection Zone does not lead to a loss of information about the system. The project can be semantically equivalently regenerated based on the Definition Zone.
*@ADR: Recognizing code as a temporary artifact is necessary to shift the focus of control to Intent, minimizing the costs of long-term legacy code support amidst the evolution of AI models.

### Principle of Infrastructure Agnosticism
ISM regulates exclusively the translation of intents into executable code. The choice of VCS (Git), branching strategy, test location (TDD in ISM or tests as a byproduct in Projection), as well as package manager management is fully delegated to the "ISM-Agent + User" pair and the current Meta-Specifications of the specific project.

### Principle of Selective Management
The ISM-Agent manages only those artifacts that are explicitly (or implicitly) represented in the Definition Zone. Files in the Projection Zone that do not have corresponding specifications or mentions in `[root]/ism/` are considered Unmanaged and are not subject to automatic synthesis or deletion. Manipulations with them require explicit coordination between the ISM-Agent and the User.
*@ADR: The principle of selectivity is introduced to prevent excessive description of trivial files, lowering the entry barrier and reducing implementation time.

### Jurisdiction Principle
Artifact management in ISM is based on topological jurisdiction:
*   **Managed Zones:** Any directory in the Projection Zone (`[root]/`) having a mirrored directory in the Definition Zone (`[root]/ism/`) is under the strict jurisdiction of the ISM-Agent. Artifacts in such a zone are defined through the corresponding Specification (Semantic or Syntactic) or indirectly via Meta-Specification. The presence of "orphan" files in this zone is qualified as Drift.
*   **Unmanaged Zones:** Any directory in the Projection Zone (`[root]/`) for which no mirror has been created in the Definition Zone (`[root]/ism/`) is outside jurisdiction. The ISM-Agent completely ignores the contents of such directories during any operations.
