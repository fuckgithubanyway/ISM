# ISM Manifest: Architectural Decision Records (ADR)

**Version:** 0.6
**Language:** English


## Concept
ADR is a **Semantic Argumentation Layer**, representing specific comments integrated directly into Specification texts to record the rationale for decisions made, prevent "Semantic Drift," and avoid accidental deletion of non-obvious solutions ("Chesterton's Fence" problem).

The true source of ADR can **only** be the Definition Zone (`[root]/ism/`). If an ADR is written in a Specification, the ISM-Agent *may* (if necessary) translate it as a comment into the text of the target Artifact (for human readability).
If a developer adds a new ADR directly into the Artifact text during debugging, this ADR has no "legal force" until a (manual or automatic) **Reconciliation** procedure extracts it from the Artifact text and integrates it into the corresponding Specification in the Definition Zone (`[root]/ism/`).


## Syntax
The **Semantic Anchoring** mechanism is used.

*   **Marker:** `@ADR:` (Case insensitive, but UPPERCASE recommended). Used as a comment prefix.
*   **Format:** `@ADR: <Text in natural language>`

*@ADR: Using a text tag instead of structured data files was chosen for maximum ease of integration into any text context and human readability.


## Application

### In Syntactic Specifications (`.ext`)
ADR is formatted as a comment immediately preceding the code block to which it refers.

`# @ADR: Using UDP instead of TCP because packet loss is acceptable, but latency is critical.`
`socket = new UdpSocket();`

ADR in a Syntactic Specification protects the specific code implementation.

### In Semantic Specifications (`.md`)
ADR is formatted as a highlighted block (Blockquote) or a separate paragraph.

`*@ADR: Transaction limit is restricted to 1000 units/sec due to bandwidth limitations of the partner's legacy gateway.`

ADR in a Semantic Specification protects the architectural logic.


## Principles

*   **Locality:** Argumentation must be located as close as possible to the decision point.

*   **Brevity:** Avoid bureaucracy. If the reason is obvious from the context, an ADR is not needed.

*   **Invariance:** Text marked with `@ADR:` has the highest priority for the ISM-Agent during refactoring. The ISM-Agent has no right to change a decision protected by an ADR without an explicit user command.

*   **Validity Criterion:** An ADR without a reason description ("Why this is done") is considered invalid (Invalid ADR). The ISM-Agent has the right to ignore such tags, notifying the User.

*   **Protection during Reconciliation:** Text marked with the `@ADR:` tag is inviolable for automatic edits by the ISM-Agent. If changes in the Projection code contradict an existing ADR, the ISM-Agent is obliged to interrupt the Reconciliation procedure and request User intervention.

*   **Protection Separation:** An ADR must protect the architectural decision, not the syntactic implementation. The ISM-Agent has the right to rewrite code under an ADR if the syntax change does not violate the logic described in the tag. (If rigid syntax fixation is required, a Syntactic Specification is used).
