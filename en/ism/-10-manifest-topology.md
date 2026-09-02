# ISM Manifest: Topology

**Version:** 0.9  
**Status:** Translation of the canonical Russian normative text

## Names

ISM file forms:

```text
-[order-]manifest-[name].md
-[order-]meta-[name].md
-[order-]spec-[target].md
-[order-]exact-[target]
```

`order` is an optional non-negative integer. It controls canonical file order only and never affects meaning, scope, or conflict resolution.

Canonical order inside a directory:

1. ISM files with `order` — by numeric `order`, then filename;
2. all remaining entries — by filename.

In the Root Definition Zone, all Manifest files must precede all other ISM files in canonical order.

`target` is the complete Target filename without a path, including its extension. The Spec location defines the path.

Examples:

```text
-10-spec-login.ts.md  -> login.ts
-20-exact-login.ts    -> login.ts
-spec-README.md.md    -> README.md
-exact-README.md      -> README.md
```

Only files matching ISM forms are normative. In a Definition Zone, `-`-prefixed filenames are reserved for ISM; a non-matching name is a Definition error. Other files are non-normative.

## Definition Zone

`[root]/ism/` is the required Root Definition Zone and contains the project Manifest Set. If Project Root is not supplied by the environment, it is the nearest ancestor whose `ism/` contains a Manifest Set.

The directory name `ism` is reserved for Definition Zones inside an ISM project.

Any `<scope>/ism/` outside another Definition Zone is a Local Definition Zone for `<scope>`. A Definition Zone cannot exist inside another Definition Zone.

For Definition Zone `D = <scope>/ism/`:

```text
D/<path>/...  <->  <scope>/<path>/...
```

A Definition Zone provides coordinates. Only a Spec defines a Target.

Symbolic links never extend ISM scope beyond Project Root and are not used to traverse external directories.

## Manifest

Manifest files are allowed only directly in the Root Definition Zone.

All Manifest files form the **Manifest Set**. Their count is unrestricted; together they define the project's ISM protocol.

The Manifest Set is read-only during normal project operations. Changing it is an ISM upgrade.

## Meta

Meta defines rules for the corresponding Projection directory and its descendants.

All Meta files for one scope form a **Meta Set**. Their count is unrestricted.

For a Target, Meta applies from general scope to more-specific scope. More-specific Meta may override less-specific Meta. Incompatible same-scope Meta is a Collision.

Meta does not define a Target.

## Semantic Spec

`-[order-]spec-[target].md` defines the required meaning of one Target: behavior, constraints, contracts, and intent.

At most one Semantic Spec may map to a Target across all project Definition Zones.

## Exact Spec

`-[order-]exact-[target]` defines the exact contents of one Target.

Exact Spec content is opaque to ISM and is interpreted only as Target content. Target must match Exact Spec exactly.

At most one Exact Spec may map to a Target across all project Definition Zones.

## Target Spec Set

Semantic and Exact Spec for the same Target form its **Target Spec Set** and may coexist. They must be compatible; contradiction is a Collision.

Removing the last Spec stops defining the Target and does not by itself authorize deletion of an existing file.

`@ABSENT` in a Semantic Spec means the Target must not exist. Such a Spec is incompatible with an Exact Spec.
