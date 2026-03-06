# ISM Manifest: Topology & Artifacts

**Version:** 0.5
**Language:** English


## Naming Convention

Files in the Definition Zone follow a strict syntax, ensuring specification type parsing and sort order management.

**Pattern:** `-[order-][type]-[name].[ext]`

*@ADR: The names of Functional Specifications and Implementation Specifications are exact pointers to the generated file.

### Name Components:
*   **prefix `-`**: Mandatory first character. Denotes the file's belonging to the ISM methodology.
*   **order (Optional sequence number)**: A numeric index in an arbitrary format (e.g., `0`, `01`, `2`, `10`, `99`, etc.). Used for forced file sorting.
    *   *Example:* File `-1-func-auth.md` will be processed or displayed before `-2-func-user.md`.
    *   *Note:* The ISM-Agent considers this order when generating documentation, but the rule application priority (Manifest > Meta > Func/Impl) remains unchanged, regardless of the number.
*   **type (Mandatory type tag)**: Keyword defining the artifact role (`manifest`, `meta`, `func`, `impl`).
*   **name (Optional identifier)**: Semantic module identifier. Anonymous Manifests and Meta-Specifications are allowed. However, anonymous Functional Specifications and Implementation Specifications are not allowed, as this would violate the Isomorphism principle.
*   **ext (Mandatory extension)**: For example, `.md` for Meta and Functional Specifications and Manifests, or `.ts`, `.js`, `.css`, `.json`, etc. for Implementation Specifications.

### Valid Name Examples:
*   `-0-manifest-core.md` (Manifest with highest sort priority)
*   `-1-manifest-topology.md` (Manifest with a sequence number)
*   `-meta-.md` (Anonymous Meta-Specification without a number)
*   `-func-logger.md` (Specification without a number)
*   `-impl-utils.ts` (Implementation Specification for a TypeScript file)


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

### Functional Specification (`-[order-]func-[name].md`)
*   **Relation:** 1 to 1. **One** Functional Specification describes the semantics of **one** target Artifact.
*   **Location:** Any directory in the Definition Zone `[root]/ism/`. Isomorphic to the target Artifact.
*   **Artifact Naming:** The generated file name is inherited from the specification's `[name]`. The extension and type of the target Artifact are determined from the context (Meta-Specification, content of the Functional Specification itself, etc.).
*   **Role:** Description of business logic, behavior, data contracts, etc.

### Implementation Specification (`-[order-]impl-[name].[ext]`)
*   **Relation:** 1 to 1. **One** Implementation Specification contains immutable text (code) blocks for **one** target Artifact in its specific implementation (`.[ext]`). Multiple `-impl-` files with the same `[name]` but different extensions (e.g., `-impl-main.c` and `-impl-main.js`) are allowed to ensure cross-platform polymorphism. The ISM-Agent selects the required file based on the current target context (Target Stack).
*   **Location:** Any directory in the Definition Zone `[root]/ism/`. Isomorphic to the target Artifact.
*   **Role:** A set of text blocks used as syntactic injections (analogous to Assembly inserts in C). Fragments of text (code) that the ISM-Agent is obliged to transfer to the target Artifact `[name]` "as is".
*   **Format:** A source file in the target format (`.[ext]`) containing text or code blocks (structures, functions, separate expressions, algorithms, etc.) accompanied by explanatory comments. Any text (code) that is **not** a comment has `Immutable` status. This is a direct syntactic injection. The ISM-Agent is obliged to transfer such text (code) to the target Artifact in the Projection Zone verbatim, without any modifications. Any text formatted as a comment in the target language (e.g., `//`, `/* */`, `#`, depending on the language) is treated by the ISM-Agent as an explanatory instruction describing the purpose of the associated block, its business logic, etc.
