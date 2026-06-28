#import "tab.typ": tab-proof-env, tab-statement-env
#import "classic.typ": classic-proof-env, classic-statement-env
#import "sidebar.typ": sidebar-proof-env, sidebar-statement-env

#let env-headers-list = ("tab", "classic", "sidebar")
#let env-headers      = state("headers", "tab")

#let valid-headers(headers) = {
  return headers in env-headers-list
}

