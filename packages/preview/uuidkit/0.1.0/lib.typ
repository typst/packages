#let plugin = plugin("plugin.wasm")

#let _namespaces = (
  dns: "dns",
  url: "url",
  oid: "oid",
  x500: "x500",
)

#let namespaces = _namespaces

#let describe(text) = json(plugin.parse(bytes(text)))
#let canonical(text) = str(plugin.normalize(bytes(text)))
#let is-uuid(text) = json(plugin.is_uuid(bytes(text)))

#let v3(namespace, name) = str(plugin.v3(bytes(namespace), bytes(name)))
#let v5(namespace, name) = str(plugin.v5(bytes(namespace), bytes(name)))

#let named(name, namespace: _namespaces.dns, version: 5) = {
  if version == 3 {
    str(plugin.v3(bytes(namespace), bytes(name)))
  } else if version == 5 {
    str(plugin.v5(bytes(namespace), bytes(name)))
  } else {
    panic("uuidkit.named only supports version 3 or 5")
  }
}
