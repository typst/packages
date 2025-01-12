import os
from pathlib import Path

IGNORE_EXTENSIONS = [
    '.pyc', '.md', '.png', '.idx', '.pack', '.rev', '.sample', '.jpg', '.xmind', '.pdf', '.docx'
]

IGNORE_FILES = [
    '.gitattributes', '.ignore', 'LICENSE'
]

def should_ignore(file_path):
    # 检查文件扩展名和文件名是否在忽略列表中
    if file_path.suffix in IGNORE_EXTENSIONS or file_path.name in IGNORE_FILES:
        return True
    return False

def generate_directory_structure(startpath, indent=''):
    structure = ""
    path = Path(startpath)
    
    if not any(path.iterdir()):
        structure += f"{indent}|-- (空目录)\n"
    else:
        for item in path.iterdir():
            if should_ignore(item):
                continue  # 忽略指定的文件或扩展名
            
            if item.is_dir():
                structure += f"{indent}|-- 文件夹: {item.name}\n"
                structure += generate_directory_structure(item, indent + '|   ')
            else:
                structure += f"{indent}|-- 文件: {item.name}\n"
    return structure

if __name__ == "__main__":
    start_path = '.'  # 可以根据需要修改为其他目录
    output_file_name = "structure.txt"
    
    directory_structure = generate_directory_structure(start_path)
    
    with open(output_file_name, 'w', encoding='utf-8') as f:
        f.write(directory_structure)

    print(f"目录结构已保存到 {output_file_name}")
