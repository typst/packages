#import "common.typ": *
#kickstart.host.verify-delete(
  host.request(),
  snapshot(),
  read-file: path => read("/" + host.path(path)),
  manifest: manifest,
)
