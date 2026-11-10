#import "../consts.typ": *
#import "../tools/lib.typ": *

#let info-default-kv = (
  info-keys.DEBUG: false,
  info-keys.宋体字体: default-info.at(info-keys.宋体字体),
  info-keys.黑体字体: default-info.at(info-keys.黑体字体),
  info-keys.等宽字体: default-info.at(info-keys.等宽字体),
  info-keys.加粗粗度: 500,
  info-keys.匿名: false,
  info-keys.论文模式: 论文模式.打印模式,
  /*
    封面参数
  */
  //
  // 作者基本参数 会影响总体封面效果
  //
  info-keys.申请学位级别: "硕士", // 硕士、博士
  info-keys.学位类型: "专业型", // 学术型、专业型
  //
  // 封面
  //
  info-keys.论文中文标题: "论文中文标题",
  info-keys.作者学科专业: "作者学科专业", // 学术型填写
  info-keys.作者专业学位类别: "作者专业学位类别", // 专业型填写
  info-keys.作者学号: "作者学号",
  info-keys.作者中文名: "作者中文名",
  info-keys.指导老师中文名: "指导老师中文名",
  info-keys.指导老师职称中文: "指导老师职称中文",
  info-keys.作者学院: "作者学院",
  //
  // 中文扉页
  //
  info-keys.分类号: "TP309.2",
  info-keys.密级: "公开",
  info-keys.UDC: "004.78",
  // 标题与已经在封面中中定义
  // 作者中文名已经在封面中定义
  // 指导老师中文名已经在封面中定义
  // 指导老师职称中文已经在封面中定义
  info-keys.指导老师单位: "指导老师单位",
  info-keys.合作导师中文名: "合作导师中文名",
  info-keys.合作导师职称中文: "合作导师职称中文",
  info-keys.合作导师单位: "合作导师单位",
  // 申请学位级别已经在作者基本参数中定义
  // 专业型: 专业学位类型 已经在封面中定义
  // 学术型: 作者学科专业 已经在封面中定义
  info-keys.专业学位领域: "专业学位领域", // 专业型填写
  info-keys.提交日期: "提交日期",
  info-keys.答辩日期: "答辩日期",
  info-keys.学位授予单位: "学位授予单位",
  info-keys.学位授予日期: "学位授予日期",
  info-keys.答辩委员会主席: "答辩委员会主席",
  info-keys.答辩委员会主席职称: "答辩委员会主席职称",
  info-keys.评阅人: ("评阅人",),
  //
  // 英文扉页
  //
  info-keys.论文英文标题: "论文英文标题",
  info-keys.作者学科专业英文: "作者学科专业英文", // 学术型填写
  info-keys.作者专业学位类别英文: "作者专业学位类别英文", // 专业型填写
  info-keys.作者英文名: "作者英文名",
  info-keys.指导老师英文名: "指导老师英文名",
  info-keys.指导老师职称英文: "指导老师职称英文",
  info-keys.作者学院英文: "作者学院英文",
  /*
    论文内容信息
  */
  // 章节参数
  info-keys.附录: none,
  info-keys.致谢: none,
  info-keys.参考文献: none,
  info-keys.中文摘要: none,
  info-keys.中文摘要关键字: none,
  info-keys.英文摘要: none,
  info-keys.英文摘要关键字: none,
  info-keys.攻读学位期间取得成果: none,
  info-keys.浮动表图标题页置底: true,
)

#let set-font-info(宋体字体: "", 黑体字体: "", 等宽字体: "") = {
  return (
    宋体: ("Times New Roman", (name: 宋体字体, covers: "latin-in-cjk")),
    黑体: ("Times New Roman", (name: 黑体字体, covers: "latin-in-cjk")),
    等宽: (等宽字体),
  )
}

#let info-check(info: (:)) = {
  let info = info
  for (key, value) in info-default-kv.pairs() {
    info = check-and-insert(info, key, value)
  }

  info.insert(
    info-keys-private.字体,
    set-font-info(
      宋体字体: info.at(info-keys.宋体字体),
      黑体字体: info.at(info-keys.黑体字体),
      等宽字体: info.at(info-keys.等宽字体),
    ),
  )

  if info.at(info-keys.匿名) {
    info.insert(info-keys.作者中文名, "*****")
    info.insert(info-keys.作者英文名, "*****")
    info.insert(info-keys.作者学号, "*****")
    // info.insert(info-keys.作者学院, "*****")
    // info.insert(info-keys.作者学院英文, "*****")
    // info.insert(info-keys.作者专业学位类别, "*****")
    // info.insert(info-keys.作者专业学位类别英文, "*****")
    // info.insert(info-keys.申请学位级别, "")
    // info.insert(info-keys.专业学位领域, "*****")

    info.insert(info-keys.指导老师中文名, "*****")
    info.insert(info-keys.指导老师英文名, "*****")
    info.insert(info-keys.指导老师职称中文, "")
    info.insert(info-keys.指导老师职称英文, "")
    info.insert(info-keys.指导老师单位, "*****")
    info.insert(info-keys.合作导师中文名, "*****")
    info.insert(info-keys.合作导师职称中文, "")
    info.insert(info-keys.合作导师单位, "*****")
  }
  return info
}
