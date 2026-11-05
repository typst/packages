#import "@preview/idraaak-step-cards:0.1.0": step-cards

// Replace these schematic illustrations with your own non-sensitive screenshots.
// See arabic.typ for a complete right-to-left example.
#show: step-cards.with(
  title: "Prepare an image for sharing",
  subtitle: "A fictional local-file workflow. The illustrations are not screenshots of a real app.",
  lang: "en",
  steps: (
    (
      title: "Choose a copy of your image",
      instruction: [Keep the original file. Select a working copy that contains no private information.],
      screenshot: image("assets/choose.svg", width: 100%, height: 100%, fit: "contain", alt: "Schematic file picker with a working copy selected."),
      check: [The selected file is the copy you intend to edit.],
    ),
    (
      title: "Review the exported file",
      instruction: [Open the result before sharing. Check its appearance, dimensions, and filename.],
      screenshot: image("assets/review.svg", width: 100%, height: 100%, fit: "contain", alt: "Schematic image preview with filename and dimensions."),
      check: [The image opens correctly and its details are readable.],
    ),
  ),
)
