#import "common.typ": *
#import "capture-config.typ" as settings
#kickstart.capture.capture(
  project-lib,
  read-file: read-file,
  settings: settings,
  manifest: manifest,
)
