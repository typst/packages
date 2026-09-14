#!/bin/bash

# format-typst.sh - Typst 代码格式化脚本
# 使用 typstyle 格式化 Typst 代码

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Typst 代码格式化工具${NC}"
    echo ""
    echo "用法: $0 [选项] [文件...]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -c, --check    仅检查格式，不修改文件"
    echo "  -a, --all      格式化所有 .typ 文件"
    echo "  -m, --main     仅格式化主要文件 (lib.typ, template/thesis.typ)"
    echo "  -v, --verbose  显示详细输出"
    echo ""
    echo "示例:"
    echo "  $0 -a                    # 格式化所有文件"
    echo "  $0 -m                    # 格式化主要文件"
    echo "  $0 -c -a                 # 检查所有文件的格式"
    echo "  $0 lib.typ               # 格式化指定文件"
    echo "  $0 pages/*.typ           # 格式化 pages 目录下的所有文件"
}

# 检查 typstyle 是否安装
check_typstyle() {
    if ! command -v typstyle >/dev/null 2>&1; then
        echo -e "${RED}错误: typstyle 未安装${NC}"
        echo ""
        echo "请安装 typstyle:"
        echo "  方法1: brew install typstyle"
        echo "  方法2: cargo install typstyle"
        echo "  方法3: 从 https://github.com/Enter-tainer/typstyle/releases 下载"
        exit 1
    fi
}

# 格式化单个文件
format_file() {
    local file="$1"
    local check_only="$2"
    local verbose="$3"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}文件不存在: $file${NC}"
        return 1
    fi
    
    if [ "$verbose" = "true" ]; then
        echo -e "${BLUE}处理: $file${NC}"
    fi
    
    if [ "$check_only" = "true" ]; then
        if typstyle --check "$file" >/dev/null 2>&1; then
            [ "$verbose" = "true" ] && echo -e "${GREEN}✅ $file 格式正确${NC}"
            return 0
        else
            echo -e "${YELLOW}❌ $file 需要格式化${NC}"
            return 1
        fi
    else
        if typstyle --inplace "$file" 2>/dev/null; then
            [ "$verbose" = "true" ] && echo -e "${GREEN}✅ $file 格式化完成${NC}"
            return 0
        else
            echo -e "${RED}❌ $file 格式化失败${NC}"
            return 1
        fi
    fi
}

# 获取所有 .typ 文件
get_all_files() {
    find . -name "*.typ" -not -path "./node_modules/*" -not -path "./.git/*" | sort
}

# 获取主要文件
get_main_files() {
    local files=()
    [ -f "lib.typ" ] && files+=("lib.typ")
    [ -f "template/thesis.typ" ] && files+=("template/thesis.typ")
    printf '%s\n' "${files[@]}"
}

# 主函数
main() {
    local check_only=false
    local format_all=false
    local format_main=false
    local verbose=false
    local files=()
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--check)
                check_only=true
                shift
                ;;
            -a|--all)
                format_all=true
                shift
                ;;
            -m|--main)
                format_main=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -*)
                echo -e "${RED}未知选项: $1${NC}"
                show_help
                exit 1
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done
    
    # 检查 typstyle
    check_typstyle
    
    # 确定要处理的文件
    local target_files=()
    
    if [ "$format_all" = "true" ]; then
        while IFS= read -r file; do
            target_files+=("$file")
        done < <(get_all_files)
    elif [ "$format_main" = "true" ]; then
        while IFS= read -r file; do
            target_files+=("$file")
        done < <(get_main_files)
    elif [ ${#files[@]} -gt 0 ]; then
        target_files=("${files[@]}")
    else
        echo -e "${RED}错误: 请指定要处理的文件或使用 -a/-m 选项${NC}"
        show_help
        exit 1
    fi
    
    if [ ${#target_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}没有找到要处理的文件${NC}"
        exit 0
    fi
    
    # 显示操作信息
    if [ "$check_only" = "true" ]; then
        echo -e "${BLUE}检查 ${#target_files[@]} 个文件的格式...${NC}"
    else
        echo -e "${BLUE}格式化 ${#target_files[@]} 个文件...${NC}"
    fi
    
    # 处理文件
    local success_count=0
    local total_count=${#target_files[@]}
    local failed_files=()
    
    for file in "${target_files[@]}"; do
        if format_file "$file" "$check_only" "$verbose"; then
            ((success_count++))
        else
            failed_files+=("$file")
        fi
    done
    
    # 显示结果
    echo ""
    if [ "$check_only" = "true" ]; then
        if [ ${#failed_files[@]} -eq 0 ]; then
            echo -e "${GREEN}✅ 所有 $total_count 个文件格式正确！${NC}"
        else
            echo -e "${YELLOW}❌ $((total_count - success_count)) 个文件需要格式化${NC}"
            echo -e "${BLUE}运行以下命令进行格式化:${NC}"
            echo "  $0 ${failed_files[*]}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ 成功格式化 $success_count/$total_count 个文件${NC}"
        if [ ${#failed_files[@]} -gt 0 ]; then
            echo -e "${RED}❌ 格式化失败的文件:${NC}"
            printf '  %s\n' "${failed_files[@]}"
            exit 1
        fi
    fi
}

# 运行主函数
main "$@"
