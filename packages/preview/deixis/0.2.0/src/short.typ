// Opt-in short aliases. Keep native block available; set is a Typst keyword.
// Export direct bindings so function identity and native behavior are preserved.
#import "setup.typ": deixis-setup-notes as setup-notes, deixis-page-overlay as page-overlay
#import "core/settings.typ": deixis-set as configure
#import "core/counter.typ": deixis-note-counter as note-counter, deixis-update-note-counter as update-note-counter
#import "layout/scopes.typ": deixis-block as note-block, deixis-minipage as minipage
#import "layout/placement.typ": deixis-place-anchored as place-anchored, deixis-absolute-place as absolute-place
#import "layout/margin.typ": deixis-margin-note-exact-layout as margin-note-exact-layout, deixis-margin-note-adaptive-layout as margin-note-adaptive-layout, deixis-margin-note-flow-layout as margin-note-flow-layout
#import "marks/inline.typ": deixis-inline-mark as inline-mark, deixis-phantom-mark as phantom-mark
#import "marks/mark.typ": deixis-mark as mark
#import "marks/region.typ": deixis-region-mark as region-mark
#import "marks/pin.typ": deixis-pin as pin, deixis-attach as attach
#import "notes/inline.typ": deixis-inline-note as inline-note, deixis-inline-note-body as inline-note-body
#import "notes/footnote.typ": deixis-footnote as footnote, deixis-footnote-body as footnote-body
#import "notes/endnote.typ": deixis-endnote as endnote, deixis-endnote-body as endnote-body, deixis-print-endnotes as print-endnotes
#import "notes/margin.typ": deixis-margin-note as margin-note, deixis-margin-note-body as margin-note-body, deixis-sidenote as sidenote, deixis-sidenote-body as sidenote-body, deixis-comment as comment
#import "notes/inset.typ": deixis-inset-note as inset-note, deixis-inset-note-body as inset-note-body
#import "render/body.typ": deixis-plain-container as plain-container, deixis-rect-container as rect-container, deixis-alert-container as alert-container, deixis-rect-region as rect-region, deixis-ellipse-region as ellipse-region, deixis-generate-backlinks as generate-backlinks, deixis-generate-body-meta as generate-body-meta, deixis-generate-body-marker as generate-body-marker, deixis-generate-body-content as generate-body-content, deixis-native-render-single as native-render-single, deixis-aligned-render-single as aligned-render-single, deixis-native-render-group as native-render-group, deixis-aligned-render-group as aligned-render-group, deixis-grid-render-group as grid-render-group
#import "render/chicago.typ": deixis-chicago-render-single as chicago-render-single
#import "reference.typ": deixis-ref as ref
#import "outline.typ": deixis-note-outline as note-outline, deixis-plain as plain
#import "query.typ": deixis-query-notes as query-notes
#import "routing/heads.typ": deixis-arrowhead as arrowhead, deixis-render-head as render-head
#import "routing/path.typ": deixis-render-connector as render-connector
#import "connection.typ": deixis-connect as connect
#import "route.typ": deixis-route as route, deixis-prepare-connector as prepare-connector
#import "route-group.typ": deixis-route-group as route-group
#import "routing/scene.typ": deixis-routing-scene as routing-scene
#import "routing/document-policy.typ": deixis-routing as routing
