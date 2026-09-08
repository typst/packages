// 构建配置：内容变体与印刷空白页由命令行输入控制

#let profile = sys.inputs.at("profile", default: "final")

#assert(
  profile in ("final", "blind", "for-print"),
  message: "profile 必须是 final、blind 或 for-print",
)

#let blind = sys.inputs.at(
  "blind",
  default: if profile == "blind" { "double" } else { "none" },
)

#assert(
  blind in ("none", "single", "double"),
  message: "blind 必须是 none、single 或 double",
)

#assert(
  profile == "blind" or blind == "none",
  message: "仅 profile=blind 允许设置盲审级别",
)

#let include-acknowledgement = (
  sys.inputs.at(
    "include-acknowledgement",
    default: if profile == "blind" { "false" } else { "true" },
  )
    == "true"
)

#let print-ready = (
  sys.inputs.at(
    "print-ready",
    default: if profile == "for-print" { "true" } else { "false" },
  )
    == "true"
)

#let twoside = sys.inputs.at("twoside", default: "true") == "true"
