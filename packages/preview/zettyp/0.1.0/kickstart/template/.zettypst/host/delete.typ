#import "common.typ": *
#eval.announce(<host.plan>, kickstart.host.delete(
  host.request(),
  snapshot(),
  read-file: path => read("/" + host.path(path)),
  manifest: manifest,
))
