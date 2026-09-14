#import "chapter.typ": chapter
#import "indexes.typ": indexes, default-indexes
#import "../i18n/i18n.typ": translate
#import "../i18n/translations.typ": i18n-words
#import "../assets/fonts.typ": fonts
#import "recipe.typ": recipe-meta-name

#let appendices(palette, custom-indexes, custom-appendices) = context {
  let recipes = query(selector(metadata))
                  .filter(x => x.value.kind == recipe-meta-name)

  let all-tags = recipes.map(r => r.value.tags)
                        .flatten()
                        .dedup()
                        .sorted()
                        
  // We show appendices only if there is tags or custom appendices
  if all-tags.len() > 0 or custom-appendices!= none {

    chapter(change-palette:palette, translate(i18n-words.appendices))

    if all-tags.len() > 0 {

      // ------- indexes pages ----------------

      set par(spacing: 0.5em)

      let local-indexes = default-indexes(recipes)
      
      if custom-indexes != none and custom-indexes.len() > 0 {
        local-indexes = custom-indexes
      }
      
      indexes(recipes, local-indexes, palette)
        
    }
    // ----------- custom appendices --------------
    custom-appendices
  }                        
}