# 模板项目 Makefile:递归编译 内容/ 下所有 .typ(PDF / 网页 / 监听)。
# 配置.typ 在项目根,内容/ 里的正文以 ../配置.typ 引用,故须 --root . 让项目根成为路径基准。
# / Template project Makefile. 配置.typ sits at the project root; chapters under
# 内容/ import it via ../配置.typ, so --root . is required.
#
# 网页是多页站点:入口 → dist/index.html,每章 → dist/<路径>/index.html,
# 收尾由 脚本/web_post.sh 抽一份公共样式表并把跨页元素连成链接。

.PHONY: pdf web watch clean

pdf:  ## 编译 内容/ 下全部 .typ 为 PDF
	@set -e; for f in $$(find 内容 -name '*.typ' | sort); do \
	  out="dist/$${f#内容/}"; out="$${out%.typ}.pdf"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  echo "PDF  $$f -> $$out"; \
	  typst compile --root . "$$f" "$$out"; \
	done

web:  ## 网页:多页站点,收尾跑 脚本/web_post.sh(HTML 导出为实验特性)
	@set -e; for f in $$(find 内容 -name '*.typ' | sort); do \
	  rel="$${f#内容/}"; \
	  case "$$rel" in \
	    index.typ)   out="dist/index.html"; src="$$f"; args="";; \
	    */index.typ) p="$${rel%/index.typ}"; out="dist/$$p/index.html"; \
	                 src="脚本/页面.typ"; args="--input 页=$$p --input 源=$$f";; \
	    *)           p="$${rel%.typ}"; out="dist/$$p/index.html"; \
	                 src="脚本/页面.typ"; args="--input 页=$$p --input 源=$$f";; \
	  esac; \
	  mkdir -p "$$(dirname "$$out")"; \
	  echo "HTML $$f -> $$out"; \
	  typst compile --root . --features html --input web=true $$args --format html "$$src" "$$out"; \
	done
	@set -e; for f in $$(find 内容 -name '*.html' | sort); do \
	  out="dist/$${f#内容/}"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  echo "COPY $$f -> $$out"; \
	  cp "$$f" "$$out"; \
	done
	@sh 脚本/web_post.sh dist

watch:  ## 监听改动,自动重编入口 PDF
	typst watch --root . 内容/index.typ dist/index.pdf

clean:  ## 清理产物
	rm -rf dist
