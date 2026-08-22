# ISM Manifest: Topology

**Version:** 0.7  
**Status:** Translation of the canonical Russian normative text

## Names

ISM file forms:

```text
-[order-]manifest-[name].md
-[order-]meta-[name].md
-[order-]spec-[target].md
-[order-]exact-[target]
```

`order` is an optional non-negative integer. It controls canonical reading and display order only; semantic priority never depends on `order`.

Canonical order inside a directory:

1. files with `order`, by numeric `order`;
2. then files without `order`;
3. ties by filename.

`target` is the full Target filename including its extension.

Examples:

```text
-10-spec-login.ts.md  -> login.ts
-20-exact-login.ts    -> login.ts
-spec-README.md.md    -> README.md
-exact-README.md      -> README.md
```

## Definition Zone

`[root]/ism/` is the Root Definition Zone. It is required and contains the project's Manifest Set.

Any `<scope>/ism/` outside another Definition Zone is a Local Definition Zone for `<scope>`. A Definition Zone cannot exist inside another Definition Zone.

For Definition Zone `D = <scope>/ism/`:

```text
D/<path>/...  <->  <scope>/<path>/...
```

A Definition Zone provides coordinates. Only a Spec provides Target ownership.

Symbolic links never extend ISM scope beyond Project Root and must not be used to traverse external directories.

## Manifest

Manifest files are allowed only directly in the Root Definition Zone.

All `manifest` files form the **Manifest Set**. Their count is unrestricted. Together they define the project's ISM protocol.

The Manifest Set is read-only during normal project operations. Changing it is an ISM upgrade.

## Meta

Meta defines rules for the corresponding Projection directory and its descendants.

All Meta files mapped to one scope form a **Meta Set**. Their count is unrestricted.

For a Target, Meta applies from general scope to specific scope. More-specific Meta overrides less-specific Meta. Incompatible Meta within the same scope is a Collision.

Meta never creates a Managed Target.

## Semantic Spec

`-[order-]spec-[target].md` defines the required meaning of one Target: behavior, constraints, contracts, and intent.

At most one Semantic Spec may map to a Target across all Definition Zones in the project.

## Exact Spec

`-[order-]exact-[target]` contains the exact contents of one Target.

Exact Spec contains no ISM directives. Target content must exactly match the Exact Spec.

At most one Exact Spec may map to a Target across all Definition Zones in the project.

## Target Spec Set

Semantic and Exact Spec for the same Target form its **Target Spec Set** and may coexist. They must be compatible; contradiction is a Collision.

A Spec makes its Target managed. Removing the last Spec makes an existing file unmanaged and does not by itself authorize deletion.

`@ABSENT` in a Semantic Spec means the Target must not exist. Such a Spec is incompatible with an Exact Spec.
