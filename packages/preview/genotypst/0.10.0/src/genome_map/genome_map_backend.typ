#let _genome-map-backend = plugin("genome_map.wasm")

/// Parses GFF3 feature data through the WASM backend.
///
/// - data (str): Raw GFF3 source.
/// - config (dictionary): Parser filter configuration.
/// -> array
#let _genome-map-parse-gff(data, config) = {
  let result = _genome-map-backend.parse_gff(
    bytes(data),
    bytes(json.encode(config, pretty: false)),
  )
  json(result)
}

/// Resolves genome-map label layout through the WASM backend.
///
/// - payload (dictionary): Label layout payload with global spacing values and
///   measured label geometry.
/// -> dictionary with keys:
///   - level-count (int): Number of occupied label levels.
///   - level-block-height (length): Total height of the label block.
///   - labels (array): Positioned backend label records.
#let _genome-map-layout-labels(payload) = {
  let result = _genome-map-backend.layout_labels(bytes(json.encode(
    (
      label_height_pt: payload.label-height / 1pt,
      label_horizontal_gap_pt: payload.label-horizontal-gap / 1pt,
      label_vertical_gap_pt: payload.label-vertical-gap / 1pt,
      label_line_distance_pt: payload.label-line-distance / 1pt,
      label_track_gap_pt: payload.label-track-gap / 1pt,
      label_leader_offset_pt: payload.label-leader-offset / 1pt,
      labels: payload.labels.map(label => (
        center_pt: label.center / 1pt,
        left_pt: label.left / 1pt,
        right_pt: label.right / 1pt,
        dodge_left_pt: label.dodge-left / 1pt,
        dodge_right_pt: label.dodge-right / 1pt,
        packing_span_pt: (label.dodge-right - label.dodge-left) / 1pt,
        gene_center_pt: label.gene-center / 1pt,
      )),
    ),
    pretty: false,
  )))
  let response = json(result)
  (
    level-count: response.level_count,
    level-block-height: response.level_block_height_pt * 1pt,
    labels: response.labels,
  )
}
