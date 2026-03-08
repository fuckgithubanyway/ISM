# ISM Manifest: Workflows & Protocols

**Version:** 0.6
**Language:** English


## Priority Cascade

When contradictions (Collisions) arise, the source with the highest priority is considered the truth:

1.  **Manifest** (Methodological foundation).
2.  **Meta-Specification** (Considering nesting).
3.  **Syntactic Specification** and **Semantic Specification**.
4.  **User Intent** (Request within the current session).

*   **Note:** Syntactic Specification (`.ext`) takes priority over Semantic Specification (`.md`) for specific code blocks (Specific overrides General). Conflict requires manual user resolution.

*@ADR: The highest priority of the Manifest guarantees that the ISM-Agent cannot violate ISM methodological principles (e.g., change logic bypassing the specification) even upon a direct user request.


## Operation Modes

### Synthesis:
*   **Vector:** From Meaning to Code.
*   **Process:** The ISM-Agent reads the specification cascade in the Definition Zone (`ism/`). Analyzes the current state of the Projection. Generates or edits existing Projection Artifacts to achieve compliance.
*   **Restrictions:** In Synthesis mode, the ISM-Agent is **forbidden** from changing the contents of the Definition Zone (`ism/`). Any generations and modifications are applied exclusively to the Projection Zone.
*   **Conflict Behavior:** If unable to safely integrate logic, the ISM-Agent interrupts Synthesis and requests conflict resolution from the **User**.

### Reconciliation:
*   **Vector:** Reverse meaning transfer.
*   **Status:** Critical operation with high risk of semantic degradation.
*   **Process:** The ISM-Agent matches the Projection against the Definition in `ism/` and detects Drift. It forms changes (updates Specifications, extracts and transfers ADRs missing in Specifications).
*   **Restrictions:** In Reconciliation mode, the ISM-Agent is **forbidden** from changing Artifacts in the Projection Zone. Its task is only to read the Projection to form proposals for changing Specifications in `ism/`.
*   **Validation:** Since changing the Definition Zone is critical, Reconciliation results require explicit confirmation (Review) from the User.

### Verification
*   **Goal:** Isomorphism check.
*   **Process:** The ISM-Agent compares the Projection with the Definition in `ism/` and detects Drift.
*   **Restrictions:** In Verification mode, the ISM-Agent is **forbidden** from making any changes to either the Definition Zone or the Projection Zone.
*   **Conflict Behavior:** In case of conflict, the ISM-Agent generates a Collision Report. Conflict resolution is the exclusive responsibility of the User.
