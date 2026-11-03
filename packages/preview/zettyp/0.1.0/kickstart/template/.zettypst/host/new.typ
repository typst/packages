#import "common.typ": *
#eval.announce(<host.plan>, kickstart.host.new(
  host.request(),
  snapshot(),
  allocate-id: kickstart.host.allocate-id,
  read-file: path => read("/" + host.path(path)),
  manifest: manifest,
))
