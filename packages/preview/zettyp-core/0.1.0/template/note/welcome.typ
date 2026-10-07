#import "../.zettypst/lib.typ": *

#show: zettel.with(
  metadata: zk_metadata.with(
    abstract: "A starting point for a ZetTypst notebook.",
  ),
)

= Welcome to ZetTypst <welcome>

This note is loaded through `.zettypst/source.toml`.
Its label declares its identity; changing the title or file path does not change that identity.

Edit `.zettypst/lib.typ` to customize shared metadata defaults and policies.
Use `zk_metadata.with(...)` to override only this note's differences.
