#import "template.typ": blueprint

// ========================================
// 📄 ats-friendly 主题示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)