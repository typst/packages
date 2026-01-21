/**
 * neurips.typ
 *
 * Template for The n-th Annual Conference on Neural Information Processing
 * Systems (NeurIPS).
 *
 * [1]: https://neurips.cc/Conferences/2023
 * [2]: https://neurips.cc/Conferences/2024
 */

// Re-export `neurips2023` rule as a general one.
#import "/neurips2023.typ": neurips2023 as neurips

#import "/neurips2023.typ": font, neurips2023, paragraph, url
#import "/neurips2024.typ": neurips2024

// Horizontal lines in table taken from booktabs.
#import "/neurips2024.typ": botrule, midrule, toprule
