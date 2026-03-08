# ISM Manifest: Topology & Artifacts

**Version:** 0.6
**Language:** English


## Naming Convention

Files in the Definition Zone follow a strict syntax, ensuring specification type parsing and sort order management.

**Pattern:** `-[order-]spec-[name].[ext]`

*@ADR: The names of Unit Specifications are exact pointers to the generated file.

### Name Components:
*   **prefix `-`**: Mandatory first character. Denotes the file's belonging to the ISM methodology.
*   **order (Optional sequence number)**: A numeric index in an arbitrary format (e.g., `0`, `01`, `2`, `10`, `99`, etc.). Used for forced file sorting.
    *   *Example:* File `-1-spec-auth.md` will be processed or displayed before `-2-spec-user.md`.
    *   *Note:* The ISM-Agent considers this order when generating documentation, but the rule application priority (Manifest > Meta > Spec) remains unchanged, regardless of the number.
*   **spec (Mandatory type tag)**: The keyword `spec`, a marker for a target specification (Semantic or Syntactic).
*   **name (Mandatory identifier)**: Semantic module identifier.
*   **ext (Mandatory extension)**: Determines the Specification subtype: `.md` for Semantic Specification, or code extension (`.ts`, `.js`, `.css`, `.json`, etc.) for Syntactic Specification.

### Valid Name Examples:
*   `-0-manifest-core.md` (Manifest with highest sort priority)
*   `-1-manifest-topology.md` (Manifest with a sequence number)
*   `-meta-.md` (Anonymous Meta-Specification without a number)
*   `-spec-auth.md` (Semantic Specification of the auth module)
*   `-spec-auth.ts` (Syntactic Specification of the auth module for TypeScript)
*   `-spec-utils.json` (Syntactic Specification for configuration)


## Structural Isomorphism

The structure of the Definition Zone mirrors the structure of the entire project relative to the root. The path `[root]/ism/foo/bar` defines the path to the artifact `[root]/foo/bar` (or a group of related artifacts).

*@ADR: Mirroring the entire root `[root]/`, rather than just the source code folder, was chosen to ensure unified management of the entire project via a single semantic protocol.

*@ADR: Duplicating the file structure (Isomorphism) is a conscious compromise. Synchronization costs are outweighed by the ability to independently translate the ISM project into different technology stacks without changing the Definition Zone.


## Specification Classification

### Manifest (`-[order-]manifest-[name].md`)
*   **Location:** Only root `[root]/ism/`.
*   **Role:** Definition of the methodology and its global laws.

### Meta-Specification (`-[order-]meta-[name].md`)
*   **Relation:** 1 to N. **One** Meta-Specification can introduce rules for **many** Artifacts.
*   **Location:** Any directory in the Definition Zone `[root]/ism/`.
*   **Role:** Setting generation rules, technology stack, architectural patterns, business context, etc., for multiple files. Acts at the directory level.
*   **Scope:** Rules of Meta-Specifications cascade to the current directory and all nested subdirectories. In case of conflict, the specification with the maximum nesting depth (closest to the target file) takes priority.
*   **Note:** Avoid excessive nesting of overloading Meta-Specifications to optimize context.
*@ADR: Cascading inheritance of Meta-Specifications allows defining local technological exceptions without complicating global project rules.

### Semantic Specification (`-[order-]spec-[name].md`)
*   **Relation:** 1 to 1. Describes the semantics of **one** target Artifact.
*   **Location:** Any directory in the Definition Zone `[root]/ism/`. Isomorphic to the target Artifact.
*   **Artifact Naming:** The generated file name is inherited from `[name]`. The extension and type are determined from the context.
*   **Priority:** Meaning (Intent).
*   **Content:** Describes "What and Why" — business logic, behavior, data contracts, developer intentions. The ISM-Agent translates this logic into executable code.

### Syntactic Specification (`-[order-]spec-[name].[ext]`)
*   **Relation:** 1 to 1. Describes the form of **one** target Artifact.
*   **Location:** Any directory in the Definition Zone `[root]/ism/`. Isomorphic to the target Artifact.
*   **Artifact Naming:** The name and extension of the target file exactly match the `[name]` and `[ext]` of the specification.
*   **Priority:** Form.
*   **Content:** Contains immutable text (code) blocks — Immutable Code Injection.
*   **Role:** Code fragments that the ISM-Agent must transfer to the target Artifact "as is", without modifications.
*   **Format:** Source file in the target format containing code blocks. Any code outside comments has `Immutable` status. Comments are treated as explanatory instructions.

### Complementarity of Specifications

Semantic (`.md`) and Syntactic (`.ext`) specifications with the same `[name]` are not mutually exclusive. They can exist in the same directory simultaneously, forming a single hybrid context for generating one target Artifact (where `.md` sets the overarching logic, and `.ext` provides exact code blocks). Priority resolution rules for their combined use are described in the Workflow manifest.
