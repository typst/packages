// #import "@preview/chef-cookbook:0.2.0": *
#import "../lib.typ": *

#show: cookbook.with(
  title: "Modern Kitchen",
  author: "Gourmet Studio",
  accent-color: rgb("#D9534F"),
  lang: "en",
  // Default language, can be overridden here for the entire cookbook
  // or on individual recipes (see below)
  custom-dicts: (
    "cz": (
      chapter: "Kapitola",
      collection: "Sbírka od ",
      contents: "Obsah",
      ingredients: "INGREDIENCE",
      chefs-note: "POZNÁMKA ŠÉFKUCHAŘE",
      preparations: "PŘÍPRAVA",
    ),
  ),
)

// --- English (Default) ---

= Starters

#recipe(
  "Roasted Tomato Basil Soup",
  description: [A comforting, velvety soup that captures the essence of late summer harvest. Perfect for chilly evenings.],
  servings: "4 bowls",
  prep-time: "15m",
  cook-time: "40m",
  ingredients: (
    (amount: "1 kg", name: "Roma tomatoes, halved"),
    (amount: "1 head", name: "Garlic, top sliced off"),
    (amount: "1/2 cup", name: "Fresh basil leaves"),
    (amount: "1 cup", name: "Vegetable broth"),
    "Olive oil",
    "Salt & pepper",
  ),
  instructions: [
    + Preheat oven to 200°C (400°F). Line a large baking sheet with parchment paper. Place tomatoes cut-side up on the baking sheet.
    + Drizzle everything generously with olive oil and season with salt and pepper. Roast for 40-45 minutes.
    + Squeeze the roasted garlic cloves out of their skins. Transfer the tomatoes and garlic to a blender.
    + Blend until smooth. Stir in heavy cream if using for extra richness.
    + Serve hot with crusty bread.
  ],
  notes: "For a vegan version, use coconut milk instead of heavy cream.",
)

= Mains

// Cookbook can be multilingual! Although the default language is English, you can specify a different language for blocks of recipes. You can either use built-in translations (currently supports German, Polish, French, Spanish, and Italian) or provide your own custom dictionary (see the 'custom-dicts' property above).

// --- German (Built-in) ---
// This uses 'de' keys from the built-in dictionary:
// ingredients: "ZUTATEN", preparations: "VORBEREITUNG"

#{
  set text(lang: "de")
  recipe(
    "Gegrillter Lachs mit Zitronen-Dill-Marinade",
    description: [Ein einfaches und elegantes Gericht, das die Frische des Lachses mit einer aromatischen Zitronen-Dill-Marinade kombiniert. Perfekt für den Sommer!],
    servings: "2 Filets",
    prep-time: "10 Min.",
    cook-time: "15 Min.",
    ingredients: (
      "2 Lachsfilets",
      "2 EL Olivenöl",
      "1 EL frischer Dill",
      "1 Zitrone, in Scheiben",
    ),
    instructions: [
      + Heizen Sie den Grill auf mittlere bis hohe Hitze vor. Bestreichen Sie die Lachsfilets mit Olivenöl.
      + Legen Sie den Lachs mit der Hautseite nach unten auf den Grill. Ca. 6–8 Minuten ohne Bewegung grillen.
      + Vorsichtig wenden und weitere 2–4 Minuten grillen.
      + Mit frischen Zitronenscheiben und Kräutern garnieren und servieren.
    ],
    notes: "Achten Sie darauf, den Lachs nicht zu lange zu garen.",
  )
}

// --- Czech (User-provided) ---
// This uses 'cz' keys from the user-provided dictionary:
// ingredients: "INGREDIENCE", preparations: "PŘÍPRAVA"


#{
  set text(lang: "cz")
  recipe(
    "Smažený sýr s hranolkami",
    description: [Klasické české jídlo, které je oblíbené mezi dětmi i dospělými. Křupavý smažený sýr podávaný s hranolkami a tatarskou omáčkou.],
    servings: "4 porce",
    prep-time: "15 min.",
    cook-time: "10 min.",
    ingredients: (
      "4 plátky tvrdého sýra (např. eidam)",
      "1 hrnek strouhanky",
      "2 vejce",
      "Olej na smažení",
      "Hranolky a tatarská omáčka k podávání",
    ),
    instructions: [
      + Plátky sýra obalte nejprve ve strouhance, poté v rozšlehaných vejcích a znovu ve strouhance.
      + V hluboké pánvi rozehřejte olej a smažte sýr dozlatova z obou stran.
      + Podávejte horké s hranolkami a tatarskou omáčkou.
    ],
    notes: "Pro extra křupavost můžete sýr před smažením zamrazit na 30 minut.",
  )
}
