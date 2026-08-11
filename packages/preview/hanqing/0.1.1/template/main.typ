#import "@preview/hanqing:0.1.1": manual, entry

#show: manual.with(
  title: "管理手册", // "Management Manual"
  author: "技术文档中心", // "Technical Documentation Center"
  accent-color: rgb("#2E5A8C"),
  toc-type: "numbly",
  menu-header: "目  录", // "Contents"
  chapter-header: "章节", // "Chapter"
)

= 项目概述 // Project Overview

#entry(
  "项目背景与目标", // "Project Background & Objectives"
  description: [本手册旨在规范项目管理流程，确保各项工作有序开展。], // This manual standardizes project management processes to ensure orderly execution.
  badge: "主责部门：项目管理办公室", // "Lead Dept: Project Management Office"
  items-header: "关键要点", // "Key Points"
  items: (
    (amount: "目标一", name: "建立统一的管理规范和标准"), // Goal 1: Establish unified management norms and standards
    (amount: "目标二", name: "明确各岗位职责与协作流程"), // Goal 2: Define role responsibilities and collaboration processes
    (amount: "目标三", name: "提供可操作的执行指南"), // Goal 3: Provide actionable implementation guidelines
    (amount: "目标四", name: "建立持续改进的反馈机制"), // Goal 4: Establish a continuous improvement feedback mechanism
  ),
  content-header: "实施步骤", // "Implementation Steps"
  content: [
    1. 成立项目管理委员会，明确组织架构和决策机制。 // Establish PM committee; define org structure and decision-making.
    2. 制定管理制度文件，经审批后正式发布。 // Draft management policy documents; publish after approval.
    3. 组织全员培训，确保制度落地执行。 // Conduct training to ensure policy implementation.
    4. 建立定期审查机制，持续优化管理流程。 // Set up periodic review to continuously optimize management.
  ],
  notes-header: "工作提示", // "Work Notes"
  notes: "本手册为内部管理文件，请妥善保管，不得外传。各章节可根据实际需要灵活调整。", // Internal document — keep confidential. Chapters may be adjusted as needed.
)

= 实施指南 // Implementation Guide

#entry(
  "质量管理流程", // "Quality Management Process"
  description: [建立全流程质量控制体系，确保交付成果符合标准要求。], // Establish end-to-end quality control system to ensure deliverables meet standards.
  badge: "主责部门：质量管理部", // "Lead Dept: Quality Management"
  items-header: "管理规则", // "Management Rules"
  items: (
    (amount: "规则一", name: "所有交付物须经质量评审后方可发布"), // Rule 1: All deliverables must pass quality review before release.
    (amount: "规则二", name: "关键节点须留存书面审核记录"), // Rule 2: Key milestones require documented review records.
    (amount: "规则三", name: "质量问题须在规定时限内完成整改"), // Rule 3: Quality issues must be resolved within specified deadlines.
  ),
  content-header: "规则解析", // "Rule Analysis"
  content: [
    1. 质量评审应在交付物完成后 3 个工作日内组织。 // Quality review should be organized within 3 working days after deliverable completion.
    2. 审核记录应包含审核人、审核日期、审核意见及整改要求。 // Review records must include reviewer, date, opinions, and corrective requirements.
    3. 一般问题整改时限为 5 个工作日，重大问题须 24 小时内响应。 // General issues: 5 working days; critical issues: 24-hour response.
  ],
  notes-header: "工作提示", // "Work Notes"
  notes: "建议使用信息化工具进行质量全流程跟踪，提高管理效率。", // Recommend using digital tools for quality tracking to improve efficiency.
)
