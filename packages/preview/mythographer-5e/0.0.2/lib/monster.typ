// This monster visualizer is compatible with 5etools schema (official). It support some "homebrew"
// setups provided by 5etools, but these haven't been tested (15/02/2026 - Sa1g).
//
//
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema-template/bestiary/bestiary.json
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema-template/util.json
// https://github.com/TheGiddyLimit/5etools-utils/blob/master/schema-template/entry.json
#import "core.typ": fn-wrapper
#import "utils.typ": merge-dicts

#import "monster/5e2014.typ": bar-5e2014, monster-5e2014
#import "monster/process/regex.typ": process-5etool-tags
#import "external.typ": transl
#import "utils.typ"

#let render-5e2014(self, correction-factor: 1, n-cols: 2, monster) = {
  let monster = monster-5e2014(self.monster, monster)
  monster = process-5etool-tags(monster)

  utils.columns-balance(
    fill: color.transparentize((self.monster.background.fill), self.monster.background.transparency), correction-factor: correction-factor, 
    n-cols: n-cols)[
    #bar-5e2014(self, top + center, dx-mod: 0, dy-mod: -1)
    #columns(n-cols)[
      #monster
    ]
    #bar-5e2014(self, bottom + center, dx-mod: 0, dy-mod: 1)
  ]
}

#let render-5e2024(monster) = {
  panic()
}

#let dnd-monster(config: (:), correction-factor: 1, columns: 2, body) = fn-wrapper(self => {
  if config != (:) {
    self = merge-dicts(self, config)
  }

  // Get shortName (get or compile)

  if self.monster.style == 2014 {
    return render-5e2014(self, correction-factor: correction-factor,  n-cols: columns, body)
  }

  if self.monster.style == 2024 {
    return render-5e2024(self, correction-factor: correction-factor, n-cols: columns, body)
  }
})
