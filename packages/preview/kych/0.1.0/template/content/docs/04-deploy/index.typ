// =============================================================================
// 文档：部署指南 (Deployment)
// =============================================================================
// 说明如何使用 GitHub Actions 将 跨越晨昏 网站自动部署到 GitHub Pages。
// =============================================================================

#import "../index.typ": template, kych
#show: template.with(title: "部署指南")

= 部署指南

// 使用 GitHub Actions 一键部署到 GitHub Pages
你可以使用 GitHub Actions 轻松将网站部署到 GitHub Pages。

// --- GitHub Actions 配置 ---
== GitHub Actions

// 在仓库中创建 .github/workflows/deploy.yml 文件
在你的仓库中创建一个名为 `.github/workflows/deploy.yml` 的文件，内容如下：


```yaml
name: Deploy

on:
  push:
    branches: [ main ]       # 推送到 main 分支时触发
  workflow_dispatch:         # 也允许手动触发

permissions:
  contents: read
  pages: write               # 写入 GitHub Pages 的权限
  id-token: write            # OIDC 令牌权限（安全部署所需）

jobs:
  # ====== 构建任务 ======
  # 在 Ubuntu 上编译网站，生成 _site/ 目录
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5          # 检出代码
      - uses: typst-community/setup-typst@v4  # 安装 Typst 编译器
      - run: make html                      # 编译生成 HTML
      - uses: actions/configure-pages@v4    # 配置 Pages
      - uses: actions/upload-pages-artifact@v4  # 上传构建产物
        with:
          path: _site                       # 指定要部署的目录

  # ====== 部署任务 ======
  # 将构建产物发布到 GitHub Pages
  deploy:
    runs-on: ubuntu-latest
    needs: build              # 依赖 build 任务完成
    permissions:
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}  # 动态获取部署 URL
    steps:
      - uses: actions/deploy-pages@v4       # 部署到 GitHub Pages
        id: deployment

```

// --- 启用 GitHub Pages ---
== 启用 GitHub Pages

// 三步操作启用 Pages
1. 前往你在 GitHub 上的仓库。
2. 导航到 _Settings_，然后进入 _Pages_。
3. 在 _Build and deployment_ 下，选择 _GitHub Actions_ 作为来源。

// 每次推送代码自动构建和部署
现在，每次你推送到 `main` 分支时，你的网站都会自动构建和部署。

