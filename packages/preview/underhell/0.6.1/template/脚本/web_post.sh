#!/bin/sh
# 网页后处理:抽公共样式表、连跨页元素、注入开合脚本。
#
# 用法:sh 脚本/web_post.sh [dist]
# make web 逐页导出 HTML 后调用。做三件模板包本身不做的多页站点级优化
# (见 web.css / lib.typ 的说明):
#   1. 样式表抽出一份 /assets/underhell.css,各页由内联 <style> 换成 <link>,多页共用;
#   2. 定义在别页的元素,由 title="未定义" 的 span 改成指向定义页的链接;
#   3. 注入目录/评论的开合脚本。
# 元素定义取自 内容/ 下的 #设定元素(level: n)[名]、显式标题标签 `= 标题 <标签>`,
# 以及 附件/元素系统.csv 的「默认」列别名:显示名与锚点 id 不同时,链接片段用 id
# (标题锚点是 id,页面上显示的却是「默认」列名,如 古龙→龙)。
#
# / Web post-processing: extract one shared /assets/underhell.css, rewrite
# cross-page element spans into links, and inject the toggle script.
# Element definitions come from 内容/ and the 附件/元素系统.csv default column.

set -e

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
root=$(CDPATH= cd "$script_dir/.." && pwd)
target=${1:-dist}
case "$target" in
  /*) dist=$target ;;
  *)  dist=$root/$target ;;
esac

tab=$(printf '\t')
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
map=$tmpdir/map.tsv          # 显示名 \t 页 URL \t 锚点
: > "$map"

# 登记元素(首次出现为准;同名以先扫到的页为准)
register() {
  name=$1
  if [ -z "$name" ]; then
    return 0
  fi
  # 按首字段精确比对(不能用 grep -F:短名会是长名前缀,如 龙 之于 古龙)
  if awk -F"$tab" -v n="$name" '$1 == n { f = 1 } END { exit !f }' "$map" 2>/dev/null; then
    return 0
  fi
  printf '%s\t%s\t%s\n' "$name" "$2" "$3" >> "$map"
}

# 扫正文里的元素定义:$1 文件,$2 该文件对应的页 URL
scan_file() {
  file=$1
  url=$2
  # #设定元素(level: n)[名]
  grep -oE '#设定元素\( *level *: *[0-9]+ *\)\[[^]]+\]' "$file" 2>/dev/null |
    while IFS= read -r m; do
      name=$(printf '%s\n' "$m" | sed -E 's/.*\[([^]]+)\]$/\1/')
      register "$name" "$url" "$name"
    done
  # 显式标题标签:= 标题 <标签>
  grep -oE '^=+ .*<[^<> 	]+>[ 	]*$' "$file" 2>/dev/null |
    while IFS= read -r m; do
      name=$(printf '%s\n' "$m" | sed -E 's/.*<([^<> 	]+)>[ 	]*$/\1/')
      register "$name" "$url" "$name"
    done
}

# 元素定义 → 所在页 URL。全量入口 内容/index.typ 即站点首页 "/"
if [ -f "$root/内容/index.typ" ]; then
  scan_file "$root/内容/index.typ" "/"
fi

# 各独立页:内容/**.typ(不含 .typ 的路径即 URL 段;目录页 内容/<目录>/index.typ → /<目录>/)
find "$root/内容" -name '*.typ' 2>/dev/null | sort > "$tmpdir/typs"
while IFS= read -r file; do
  rel=${file#"$root/内容/"}
  case "$rel" in
    index.typ)   continue ;;
    */index.typ) page=${rel%/index.typ} ;;
    *)           page=${rel%.typ} ;;
  esac
  scan_file "$file" "/$page/"
done < "$tmpdir/typs"

# CSV:元素 id 与「默认」显示名不同的,把显示名一并登记(HTML 里显示的是默认名),
# 锚点仍用 id。
csv=$root/附件/元素系统.csv
if [ -f "$csv" ]; then
  awk -F, 'NR > 1 { gsub(/\r/, "", $1); gsub(/\r/, "", $2); if ($1 != "") print $1 "\t" $2 }' "$csv" |
    while IFS="$tab" read -r eid disp; do
      if [ -z "$eid" ]; then
        continue
      fi
      if [ -z "$disp" ]; then
        disp=$eid
      fi
      if [ "$disp" != "$eid" ]; then
        url=$(awk -F"$tab" -v n="$eid" '$1 == n { print $2; exit }' "$map" 2>/dev/null || true)
        if [ -n "$url" ]; then
          register "$disp" "$url" "$eid"
        fi
      fi
    done
fi

find "$dist" -name '*.html' 2>/dev/null | sort > "$tmpdir/htmls"
if [ ! -s "$tmpdir/htmls" ]; then
  echo "web_post: 未找到 HTML 产物"
  exit 0
fi

# ---------- 内嵌网页样式 → 外部 /assets/underhell.css ----------
found=0
while IFS= read -r file; do
  if grep -qF '<style>/*uh-raw*/' "$file" 2>/dev/null; then
    awk '
      BEGIN { on = 0 }
      {
        if (!on) {
          i = index($0, "<style>/*uh-raw*/")
          if (i == 0) next
          on = 1
          s = substr($0, i + length("<style>"))
        } else {
          s = $0
        }
        j = index(s, "</style>")
        if (j > 0) { if (j > 1) print substr(s, 1, j - 1); exit }
        print s
      }
    ' "$file" > "$tmpdir/underhell.css"
    found=1
    break
  fi
done < "$tmpdir/htmls"

if [ "$found" = 1 ] && [ -s "$tmpdir/underhell.css" ]; then
  mkdir -p "$dist/assets"
  cp "$tmpdir/underhell.css" "$dist/assets/underhell.css"
elif [ ! -f "$dist/assets/underhell.css" ]; then
  echo "web_post: 未找到内嵌网页样式,跳过 CSS 抽取"
fi

# 交互脚本:目录/评论触发点点击开合(幂等,靠标记 uhTocToggle 判定)
JS="<script>(function(){var uhTocToggle=1;document.addEventListener('click', function(e){var head = e.target.closest('.uh-toc-head');if (head) {var toc = head.closest('.uh-toc');toc.classList.toggle('uh-open');head.setAttribute('aria-expanded', toc.classList.contains('uh-open'));return;}var tr = e.target.closest('.uh-comment-trigger');if (tr) {var panel = tr.nextElementSibling;if (panel) panel.classList.toggle('uh-open');}});})();</script>"

# ---------- 逐页:内嵌样式 → 外链,跨页元素 span → 链接 ----------
total=0
while IFS= read -r file; do
  rel=${file#"$dist/"}
  case "$rel" in
    */*) page="/${rel%/*}/" ;;
    *)   page="/" ;;
  esac
  n=$(awk -v map="$map" -v page="$page" -v out="$tmpdir/out.html" '
    BEGIN {
      while ((getline l < map) > 0) {
        k = index(l, "\t")
        if (k == 0) continue
        name = substr(l, 1, k - 1)
        rest = substr(l, k + 1)
        k2 = index(rest, "\t")
        if (k2 > 0) { URL[name] = substr(rest, 1, k2 - 1); ANCH[name] = substr(rest, k2 + 1) }
        else        { URL[name] = rest;                    ANCH[name] = rest }
      }
      close(map)
      SPAN = "<span class=\"uh-element\" title=\"未定义\">"
      ENDS = "</span>"
      STYOPEN = "<style>/*uh-raw*/"
      STYCLOSE = "</style>"
      link = "<link rel=\"stylesheet\" href=\"/assets/underhell.css\">"
      instyle = 0
      cnt = 0
    }
    # 未定义 span 若定义在别页,改成指向该页(锚点用 id)的链接;本页定义或无定义的保持原样
    function rewrite(s,   o, i, pre, rest, e, m, gt, name, tgt, anc) {
      o = ""
      while ((i = index(s, SPAN)) > 0) {
        pre = substr(s, 1, i - 1)
        rest = substr(s, i)
        e = index(rest, ENDS)
        if (e == 0) { o = o s; s = ""; break }
        m = substr(rest, 1, e + length(ENDS) - 1)
        s = substr(rest, e + length(ENDS))
        gt = index(m, ">")
        name = substr(m, gt + 1, length(m) - gt - length(ENDS))
        tgt = URL[name]
        if (tgt != "" && tgt != page) {
          anc = (name in ANCH && ANCH[name] != "") ? ANCH[name] : name
          o = o pre "<a href=\"" tgt "#" anc "\"><span class=\"uh-element\">" name "</span></a>"
          cnt++
        } else {
          o = o pre m
        }
      }
      return o s
    }
    {
      line = $0
      o = ""
      if (instyle) {
        j = index(line, STYCLOSE)
        if (j == 0) next
        instyle = 0
        line = substr(line, j + length(STYCLOSE))
      }
      i = index(line, STYOPEN)
      if (i > 0) {
        pre = substr(line, 1, i - 1)
        rest = substr(line, i)
        j = index(rest, STYCLOSE)
        if (j > 0) o = pre link substr(rest, j + length(STYCLOSE))
        else { o = pre link; instyle = 1 }
      } else {
        o = line
      }
      r = rewrite(o)
      print r > out
    }
    END { print cnt }
  ' "$file")
  mv "$tmpdir/out.html" "$file"

  if ! grep -qF 'uhTocToggle' "$file" 2>/dev/null; then
    printf '%s\n' "$JS" >> "$file"
  fi
  total=$((total + ${n:-0}))
done < "$tmpdir/htmls"

echo "web: $(wc -l < "$tmpdir/htmls" | tr -d ' ') 页;CSS 抽取;跨页元素链接 $total 个"
