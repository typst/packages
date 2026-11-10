// demo-data.typ — Thin loader for shared JSON datasets
//
// Five themed datasets cover every chart data shape:
//   sales.*     — SaaS company metrics (bars, lines, funnels, gauges, flows)
//   codebase.*  — Open source project stats (lollipops, waffle, chord, word cloud)
//   league.*    — Soccer league data (radar, scatter, distributions, rankings)
//   rpg.*       — D&D campaign tracker (characters, combat, quests, loot)
//   words.*     — Data visualization vocabulary (word cloud, categories)

#let sales    = json("../data/sales.json")
#let codebase = json("../data/codebase.json")
#let league   = json("../data/league.json")
#let rpg      = json("../data/rpg.json")
#let words    = json("../data/words.json")
