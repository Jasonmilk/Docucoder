#!/bin/bash
# DocuCoder 智能版本治理系统2.0 安装脚本
# 最后更新: 2025-02-09

set -e  # 遇到错误立即退出

# ---------- 配置参数 ----------
VSCODE_EXTENSIONS=(
    "alefragnani.project-manager"   # 项目管理
    "yzhang.markdown-all-in-one"    # Markdown增强
)
PYTHON_SCRIPTS=(
    "https://docucoder.cc/v2/version_tracker.py"
    "https://docucoder.cc/v2/pre_check.sh"
)
GIT_HOOKS=(
    "post-commit=https://docucoder.cc/v2/hooks/post-commit"
)
CONFIG_FILES=(
    "vscode_settings.json=>.vscode/settings.json"
    "aitoken.toml=>.aitoken.toml"
)

# ---------- 安装函数 ----------
install_core() {
    echo "🛠️ 开始安装DocuCoder核心组件..."
    
    # 创建项目结构
    mkdir -p .vscode .git/hooks
    
    # 安装VS Code插件
    for ext in "${VSCODE_EXTENSIONS[@]}"; do
        code --install-extension $ext --force
    done
    
    # 下载Python工具
    for script in "${PYTHON_SCRIPTS[@]}"; do
        curl -s $script -O
        chmod +x $(basename $script)
    done
    
    # 配置Git钩子
    for hook in "${GIT_HOOKS[@]}"; do
        name=${hook%%=*}
        url=${hook#*=}
        curl -s $url -o .git/hooks/$name
        chmod +x .git/hooks/$name
    done
    
    # 部署配置文件
    for cfg in "${CONFIG_FILES[@]}"; do
        url=${cfg%%=>*}
        path=${cfg#*=>}
        curl -s https://docucoder.cc/v2/configs/$url -o $path
    done
    
    echo "✅ 核心组件安装完成！"
}

# ---------- 主执行流程 ----------
if [ "$1" = "--lite" ]; then
    echo "🔄 轻量模式安装（跳过AI组件）..."
    install_core
else
    echo "🚀 完整模式安装..."
    install_core
    
    # 安装AI辅助组件
    echo "🧠 部署AI辅助规则..."
    curl -s https://docucoder.cc/v2/ai_rules.json -o .airules.json
    pip3 install -q semantic_version==2.10.0
fi

# ---------- 验证安装 ----------
echo "🔍 运行安装验证..."
if [ -f "version_tracker.py" ] && [ -f ".vscode/settings.json" ]; then
    echo "✔️  所有组件验证通过"
else
    echo "❌ 安装异常，请检查网络连接后重试"
    exit 1
fi

echo "🎉 安装成功！重启IDE后生效"
