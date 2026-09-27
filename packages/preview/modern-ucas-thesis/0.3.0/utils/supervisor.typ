// 导师信息工具
//
// 规范要求指导教师同时填写"姓名、专业技术职务、工作单位"三项，
// 多导师时第一导师在前。本模块定义导师的统一数据结构与渲染方式，供封面/摘要使用。
//
// 统一数据表示：每位导师为一个字典
//   (name: <姓名>, title: <专业技术职务>, affiliation: <工作单位>)
// 多导师为该字典的列表，第一导师在前。空字段用空字符串 "" 占位（渲染时自动跳过）。

// 校验并补齐单个导师字典，确保含 name/title/affiliation 三个字段。
#let _normalize-one(sup) = {
  if type(sup) != dictionary {
    panic(
      "导师项必须是字典 (name:, title:, affiliation:)，得到 "
        + str(type(sup))
        + "："
        + repr(sup)
        + "。",
    )
  }
  (
    name: sup.at("name", default: ""),
    title: sup.at("title", default: ""),
    affiliation: sup.at("affiliation", default: ""),
  )
}

// 将导师字段归一化为字典列表。
// 接受单个字典（包成单元素列表）或字典列表；空值返回空列表。
#let normalize-supervisors(supervisors) = {
  if supervisors == none or supervisors == () or supervisors == "" {
    return ()
  }
  if type(supervisors) == dictionary {
    return (_normalize-one(supervisors),)
  }
  if type(supervisors) == array {
    return supervisors.map(_normalize-one)
  }
  panic(
    "导师字段必须是字典或字典列表，得到 "
      + str(type(supervisors))
      + "："
      + repr(supervisors)
      + "。",
  )
}

// 将一位导师渲染为中文单行字符串："姓名 职称 工作单位"（空字段跳过，项间空格分隔）
// 用于研究生封面单栏下划线内填三项的场景（样张1：姓名、专业技术职务、工作单位）。
#let supervisor-line(sup) = {
  (
    sup.at("name", default: ""),
    sup.at("title", default: ""),
    sup.at("affiliation", default: ""),
  )
    .filter(s => s != "")
    .join(" ")
}

// 将一位导师渲染为英文单行字符串："title name affiliation"（职称在前，符合英文习惯）
// 用于研究生英文封面 "Supervisor(s):" 行（英文习惯 "Professor Si Li" 而非 "Si Li Professor"）。
#let supervisor-en-line(sup) = {
  let parts = ()
  if sup.at("title", default: "") != "" { parts.push(sup.at("title")) }
  if sup.at("name", default: "") != "" { parts.push(sup.at("name")) }
  if sup.at("affiliation", default: "") != "" {
    parts.push(sup.at("affiliation"))
  }
  parts.join(" ")
}
