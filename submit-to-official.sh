#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 提交 cookbook-cn + touying-bamboo 到 typst/packages
# 无需下载官方仓库，直接用现有 fork
# ============================================================

REPO_DIR="/home/song/NutstoreFiles/projects/typst-packages"
NEW_BRANCH="submit-cookbook-cn-touying-bamboo"
TMP_DIR=$(mktemp -d)

cd "$REPO_DIR"

echo "==> 1/5 从当前分支导出包文件..."
git checkout add-cookbook-cn
cp -r packages/cookbook-cn   "$TMP_DIR/"
cp -r packages/touying-bamboo "$TMP_DIR/"

echo "==> 2/5 基于 main 创建新分支..."
git checkout main
git checkout -B "$NEW_BRANCH"

# 确保目录干净
rm -rf packages/cookbook-cn packages/touying-bamboo 2>/dev/null || true

echo "==> 3/5 拷贝包文件到 packages/preview/..."
mkdir -p packages/preview
cp -r "$TMP_DIR/cookbook-cn"    packages/preview/cookbook-cn
cp -r "$TMP_DIR/touying-bamboo" packages/preview/touying-bamboo

echo "==> 4/5 提交 & 推送..."
git add packages/preview/cookbook-cn packages/preview/touying-bamboo
git commit --no-gpg-sign -m "Add cookbook-cn:0.1.0 and touying-bamboo:0.1.0"
git push origin "$NEW_BRANCH" --force

echo "==> 5/5 创建 PR 到 typst/packages..."
gh pr create \
  --repo typst/packages \
  --base main \
  --head "songwupei:$NEW_BRANCH" \
  --title "Add cookbook-cn:0.1.0 and touying-bamboo:0.1.0" \
  --body 'I am submitting
- [x] a new package
- [ ] an update for a package

## cookbook-cn
A Typst cookbook template with full Chinese typography support - Zhuque Fangsong and LXGW WenKai fonts, custom cover pages with subtitle lines, numbered or simple TOC styles, configurable section headers, and version stamping. Forked from chef-cookbook by PaulMue0.

## touying-bamboo
A clean bamboo-green theme for the Touying presentation framework, featuring slide counters, section dividers, focus slides, and a centered title slide layout.

---
I have read and followed the submission guidelines and, in particular, I
- [x] selected a name that is not the most obvious or canonical name
- [x] added a typst.toml file with all required keys
- [x] added a README.md with documentation
- [x] have chosen a license and added a LICENSE file
- [x] tested my package locally on my system and it worked
- [x] excluded PDFs or README images, if any, but not the LICENSE
- [x] cookbook-cn template is licensed for unrestricted use and distribution'

rm -rf "$TMP_DIR"
echo ""
echo "✅ 完成！"
