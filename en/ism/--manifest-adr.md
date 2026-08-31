# ISM Manifest: ADR

**Version:** 0.8  
**Status:** Translation of the canonical Russian normative text

## Purpose

ADR protects a non-obvious decision from accidental change.

Format:

```text
@ADR: <decision; reason>
```

ADR must include a reason. If the reason is obvious, ADR is unnecessary.

## Rules

- ADR is allowed in Manifest, Meta, and Semantic Spec.
- ADR is forbidden in Exact Spec.
- ADR has authority only from Definition.
- ADR does not change the priority of its containing rule and cannot contradict a higher level.
- ISM-Agent does not change a protected decision without an explicitly approved Definition change.
- ADR found in Projection has no normative authority and is only a candidate during Reconciliation.

Place ADR as close as possible to the protected decision and keep it minimal.
