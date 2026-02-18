#import "tab.typ": tab_proof_env, tab_statement_env
#import "classic.typ": classic_proof_env, classic_statement_env
#import "sidebar.typ": sidebar_proof_env, sidebar_statement_env

#let env_headers_list = ("tab", "classic", "sidebar")
#let env_headers      = state("headers", "tab")

#let valid_headers(headers) = {
  return headers in env_headers_list
}

