#let patterns = (
  element: regex("^\s*?([A-Z][a-z]?)\s?(\\d+[a-z]*|[a-z])?"),
  coefficient: regex("^\\s*(\\d+\\.?\\d*)"),
  bracket: regex("^\\s*([\\(\\[\\{\\}\\]\\)])\\s*(\d*|[a-z]+)?"),
  charge: regex("^\\^\\(?([0-9]*(\\+|\\-)+|\\+|\\-[0-9]*)\\)?"),
  state: regex("^\\((s|l|g|aq|soln|solid|liquid|gas|aqueous)\\)"),
  arrow: regex("^\\s*(<->|<==?>|-->|->|=|⇌|⇒|⇔)"),
  plus: regex("^\\s*\\+"),
  heating: regex("^\\s*(Δ|δ|Delta|delta|heat|fire|hot|heating)\\s*"),
  temperature: regex("^\\s*([Tt])\\s*=\\s*(\\d+\\.?\\d*)\\s*([K°C℃F])?"),
  pressure: regex("^\\s*([Pp])\\s*=\\s*(\\d+\\.?\\d*)\\s*(atm|bar|Pa|kPa|mmHg)?"),
  catalyst: regex("^\\s*(cat|catalyst)\\s*=?\\s*([A-Za-z0-9\\s]+)"),
  parameter: regex("^\\s*([A-Za-z0-9]+)\\s*=?\\s*([A-Za-z0-9\\s]+)"),
  comma: regex("^\\s*,\\s*"),
  whitespace: regex("^\\s+"),
  number: regex("^\\d+\\.?\\d*"),
)

// === 移除非正则表达式相关部分 ===
// 配置和处理逻辑将移至lib.typ
