// =============================================================================
// unsa-epis-abet-report: UNSA EPIS ABET-compliant laboratory report template
// =============================================================================

// Public utilities
#import "src/utils.typ": (
  abbreviate-by-caps, abbreviate-full-name, font-build, normalize-color,
  to-plain-string,
)

// Modular section boxes
#import "src/components/boxes.typ": (
  bibliography-box, feedback-box, results-section,
)

// Core show-rule template orchestrator
#import "src/layout.typ": abet-report, unsa-epis-abet-report
