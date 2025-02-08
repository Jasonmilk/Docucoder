import os
import subprocess
from datetime import datetime

def get_git_tag(path):
    try:
        return subprocess.check_output(
            ['git', 'describe', '--tags', '--always'], 
            cwd=path
        ).decode().strip()
    except:
        return 'dev'

def generate_structure(output='structure.md', max_depth=3):
    with open(output, 'w', encoding='utf-8') as f:
        f.write(f'# 项目版本地图（生成于 {datetime.now()}）\n\n')
        for root, dirs, files in os.walk('.'):
            if '/.git' in root or '/.vscode' in root:
                continue
            
            level = root.count(os.sep)
            if level > max_depth:
                continue
                
            indent = '  ' * level
            version = get_git_tag(root)
            base_name = os.path.basename(root) or '根目录'
            
            f.write(f'{indent}- **{base_name}** `({version})`\n')
            
            if level == max_depth-1:
                f.write('<details>\n<summary>子模块详情</summary>\n')
                
            for file in files:
                if file.endswith('.md'):
                    f.write(f'{indent}  - 📄 {file}\n')
                    
            if level == max_depth-1:
                f.write('</details>\n\n')

if __name__ == '__main__':
    generate_structure()
