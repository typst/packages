#import "@preview/resume-ng:1.0.0": *

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Resume-ng",
  author: (name: "冯开宇"),
  contacts: 
    (
      "+86 188-888-8888",
       link("mailto:loveress01@outlook.com", "loveress01@outlook.com"),  
       link("https://blog.fkynjyq.com", "blog.fkynjyq.com"),
       link("https://github.com", "github.com/fky2015"),  
    )
)

#resume-section("教育经历")
#resume-education(
  university: "北京理工大学",
  degree: "学术型硕士研究生",
  school: "网络空间安全，网络空间安全学院",
  start: "2021-09",
  end: "2024-06"
)[
*GPA: 3.62/4.0*，主要研究方向为#strong("拜占庭共识算法")，在分布式系统领域方面有一定的研究和工程经验。*2024年应届生*。
]

#resume-education(
  university: "北京理工大学",
  degree: "工学学士",
  school: "计算机科学与技术，计算机学院",
  start: "2017-09",
  end: "2021-06"
)[
*GPA: 3.7/4.0(专业前 3\%)*，获学业奖学金多次，全国大学生 XYZ 竞赛二等奖（2次），ZYX 竞赛三等奖。
]

#resume-section[技术能力]
- *语言*: 编程不受特定语言限制。常用 Rust, Golang, Python,C++； 熟悉 C, #text(fill: gray, "JavaScript")；了解 Lua, Java, #text(fill: gray, "TypeScript")。
- *工作流*: Linux, Shell, (Neo)Vim, Git, GitHub, GitLab.
- *其他*: 有容器化技术的实践经验，熟悉 Kubernetes 的使用。

#resume-section[工作经历]
#resume-work(
  company: "北京 ABCD 有限公司",
  duty: "后端开发实习生/XXXX",
  start: "2020.10",
  end: "2021.03",
)[
- *独立负责XXX业务后端的设计、开发、测试和部署。*通过 FaaS、Kafka 等平台实现站内信模板渲染服务。向上游提供 SDK 代码，增加或升级了多种离线和在线逻辑。完成了业务对站内信的多样需求。
- *参与 XXX 的需求分析，系统技术方案设计；完成需求开发、灰度测试、上线和监控。*
]

#resume-section[项目经历]

#resume-project(
  title: "BusTub 基于 C++ 的简易单机数据库",
  duty: "算法设计与实现 / CMU 15-445 课程",
)[
  - 实现了基于可扩展哈希表和LRU-K的内存池管理。实现了可并发的B+树，支持乐观加锁的读写操作。
  - 采用火山模型实现了查询、修改、连接、聚合等查询执行器，对部分查询进行了改写与下推。
  - 采用 2PL 进行并发控制，支持死锁处理、多种隔离级别、表锁和行锁。
  - 对数据库系统有了基本的认识和实践。
]

#resume-project(
  title: "Multi-Raft 分布式 KV 存储系统",
  duty: "算法设计与实现 / MIT 6.824 课程",
)[
  - 实现了 Raft 协议的选举、日志复制、持久化、日志压缩等基本功能。
  - 基于 Raft 协议实现了满足线性一致性的 KV 数据库。
  - 采用 Multi-Raft 架构，支持数据分片，分片迁移，分片垃圾回收和分片迁移时读写优化。
  - 对分布式系统的设计考量有了更多的认识。
]

#resume-project(
  title: "ZYX 平台下的某某共识算法设计与实现",
  duty: "共识算法设计与实现",
  start: "2021.11",
  end: "2022.07",
)[
  - 根据 ZYX (Rust 实现的开源区块链框架) 的架构，*修改并实现某某某共识算法*。
  - 针对系统进行性能测试，分析瓶颈，并优化吞吐量；TPS 由 1K 达到 6K。
  - 此项目为实验室研究项目的一部分。
]

#resume-project(
  title: "BIThesis 北京理工大学毕设模板集合(开源项目)",
  duty: "主要维护者（开源项目）",
  start: "2020.04",
)[
  - 根据相关排版要求，*利用 LaTeX3 (expl3) 设计了同时符合各个学位要求且支持灵活配置的宏包及多套模板*。
  - 需求开发和问题修复采用标准工作流，引入了回归测试与基于 GitHub Actions 的测试与持续集成。
  - 负责了什么什么；完成了怎样的结果。
]

#resume-section[个人总结]

- 本人乐观开朗、在校成绩优异、自驱能力强，具有良好的沟通能力和团队合作精神。
- 可以使用英语进行工作交流（六级成绩 XXX），平时有阅读英文书籍和口语练习的习惯。
- 有六年 Linux 使用经验，较为丰富的软件开发经验、开源项目贡献和维护经验。善于技术写作，持续关注互联网技术发展。
