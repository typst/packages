// The growing annotation registry is boxed in content. Typst hashes call
// arguments and caches content hashes, so the many settings lookups that receive
// the system state no longer rehash every registered note.
#let _deixis-empty-registry = (
  note-uid: 0,
  counters: (:), // count-id -> (series -> integer), without delimiter aliases
  notes: (:), // str(internal-id) -> note-data
  id-index: (:), // str(id) -> str(internal-id)
  pending-bodies: (:), // Explicit IDs whose mark has not occurred yet.
  // Wrapper-owned identities: parallel location/uid lists in registration order.
  auto-locs: (),
  auto-uids: (),
)
#let deixis-system = std.state("deixis-system", (
  stack: (),
  blocks: (:),
  registry: metadata(_deixis-empty-registry),
))
#let _deixis-registry(sys) = sys.at("registry", default: metadata(_deixis-empty-registry)).value
// Write it back inline as `sys + (registry: metadata(registry))`. A helper
// receiving the unboxed registry would hash the whole record on every call.
#let deixis-setup-state = std.state("deixis-setup-state", false)

// Block construction needs scope geometry/counter ownership before its content
// exists. Keep that read independent of annotation payloads in the registry:
// contextual IDs in an earlier block must not affect a later block's creation.
#let _deixis-layout-scopes = std.state("deixis-layout-scopes", (stack: (), blocks: (:)))

// Creation policy stays independent of registrations so deciding whether a
// declaration exists cannot wait on counters or bodies that it would create.
#let _deixis-omission-policy = std.state("deixis-omission-policy", (none,))
