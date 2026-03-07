#import "@preview/chef-cookbook:0.1.0": *

#show: cookbook.with(
  title: "Modern Kitchen",
  author: "Gourmet Studio",
  accent-color: rgb("#D9534F"),
)

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
    1. Preheat oven to 200°C (400°F). Line a large baking sheet with parchment paper. Place tomatoes cut-side up on the baking sheet.
    2. Drizzle everything generously with olive oil and season with salt and pepper. Roast for 40-45 minutes.
    3. Squeeze the roasted garlic cloves out of their skins. Transfer the tomatoes and garlic to a blender.
    4. Blend until smooth. Stir in heavy cream if using for extra richness.
    5. Serve hot with crusty bread.
  ],
  notes: "For a vegan version, use coconut milk instead of heavy cream.",
)

= Mains

#recipe(
  "Lemon Herb Grilled Salmon",
  description: [Light, zesty, and packed with healthy omega-3s. This salmon comes together in under 30 minutes.],
  servings: "2 fillets",
  prep-time: "10m",
  cook-time: "15m",
  ingredients: (
    "2 salmon fillets",
    "2 tbsp olive oil",
    "1 tbsp fresh dill",
    "1 lemon, sliced",
  ),
  instructions: [
    1. Preheat your grill to medium-high heat. Brush the salmon fillets with olive oil.
    2. Place the salmon on the grill, skin-side down. Cook for about 6-8 minutes without moving it.
    3. Flip carefully and cook for another 2-4 minutes.
    4. Serve garnished with fresh lemon slices and extra herbs.
  ],
  notes: "Be careful not to overcook the salmon.",
)
