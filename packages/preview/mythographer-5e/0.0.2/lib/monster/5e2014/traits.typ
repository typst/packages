#import "../process/trait-action-entry.typ": process-trait-action-entry
#import "../process/spellcasting.typ": process-spells
#let render-traits(self, body) = {
  process-trait-action-entry("trait", body)
  process-spells(body)
}