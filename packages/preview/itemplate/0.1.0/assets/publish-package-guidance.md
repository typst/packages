

```powershell
# 1. 克隆仓库（使用 HTTPS 替代 SSH）
# --depth 1: 只下载最新的一次提交记录，极大减少下载量
# --no-checkout: 克隆后不立即检出文件，配合稀疏检出使用
# --filter="tree:0": 不下载文件内容，只下载目录结构，进一步加速
git clone --depth 1 --no-checkout --filter="tree:0" https://github.com/hexiongwu1995/packages.git
# 2. 进入项目目录
cd packages

# 3. 初始化稀疏检出模式
# 这一步告诉 Git 我们只想检出部分文件，而不是整个巨大的仓库
git sparse-checkout init

# 4. 设置你要操作的目录
# 这里指定了你要发布的包的路径，Git 只会把这个目录的文件下载下来
git sparse-checkout set packages/preview/theoframe/ packages/preview/itemplate/

# 5. 添加上游仓库（官方仓库）
# 这一步非常重要，它把你自己的 Fork 和 Typst 官方仓库关联起来
# 以后你需要用这个 upstream 来同步官方最新的包列表
git remote add upstream https://github.com/typst/packages.git

# 6. 配置上游仓库的过滤规则
# 确保从官方仓库拉取数据时，也只使用稀疏模式，保持轻量
git config remote.upstream.partialclonefilter tree:0

# 7. 切换到主分支
# 此时你的本地文件夹里应该只会出现 packages/preview/theoframe 这个目录了
git checkout main
```