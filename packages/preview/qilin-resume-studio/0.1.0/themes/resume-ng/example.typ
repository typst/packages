#import "template.typ": blueprint

// ========================================
// 📄 resume-ng 主题示例
// ========================================

#let data = yaml("example.yml")

#show: blueprint.with(data: data)