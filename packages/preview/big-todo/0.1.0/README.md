# Big-TODO

Create clearly visible TODOs in your document, and add an outline to keep track of them.

## Usage

Import the package

```typst
import "@preview/big-todo:0.1.0": *
```

And use the `todo` function to create a TODO, and the put the `todo_outline` somewhere to keep track of them.

```typst
= Pirates

Pirates, a term often associated with seafaring outlaws, have left an indelible mark on world history. The term conjures images of Jolly Roger flags, eye patches, and treasure chests, but the reality of piracy is more complex and varied than its romanticized image suggests. Historically, pirates were motivated by wealth, adventure, or desperation and were not confined to the seas of the Caribbean but roamed the waters of the Mediterranean, the South China Sea, and the Atlantic Ocean. Pirate societies were notorious for their flouting of societal norms, and many pirate ships operated under democratic principles, offering crew members an equal share in the spoils and voting rights on important decisions. To get a better picture, it's worth looking into how the social structures onboard these pirate vessels contrasted with those on merchant or navy vessels of the same era. #todo([Research and provide more _detail_ on #underline[pirate ship] governance and societal norms ])

Pirates' influence on history extends beyond their shipboard societies, however. Many pirates played important roles in global trade, war, and politics, often acting as privateers for countries at war. At times, they acted as de facto naval forces, protecting their patron countries' interests or disrupting those of their enemies. During the Golden Age of Piracy, roughly from 1650 to 1720, pirates were a major force in the Atlantic and the Caribbean, attacking the heavily laden ships of the Spanish Empire and others. They have also impacted popular culture, inspiring countless books, movies, and games. But their story is not finished. Modern-day piracy, especially off the coast of Somalia, has become a significant issue in international shipping.

#todo_outline
```

![Screenshot of above Example](screenshot.png "Screenshot of above Example")

The `todo` function has the follwin parameters and defaults:

| Parameter    | Default | Type    | Description                                     |
| ------------ | ------- | ------- | ----------------------------------------------- |
| `body`       | /       | Content | Content of the todo                             |
| `big_text`   | 40pt    | Length  | Size of the `! TODO !` text                     |
| `small_text` | 15pt    | Length  | Size of the content                             |
| `gap`        | 2mm     | Length  | Gap between the `! TODO !` text and the content |