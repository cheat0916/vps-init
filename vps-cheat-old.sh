#!/bin/bash

# ========== 颜色定义 ==========
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

# ========== LOGO ==========
CHEAT_LOGO="
${GREEN}   ▄████▄   ██░ ██ ▓█████ ▓█████▄ ▄▄▄█████▓
  ▒██▀ ▀█  ▓██░ ██▒▓█   ▀ ▒██▀ ██▌▓  ██▒ ▓▒
  ▒▓█    ▄ ▒██▀▀██░▒███   ░██   █▌▒ ▓██░ ▒░
  ▒▓▓▄ ▄██▒░▓█ ░██ ▒▓█  ▄ ░▓█▄   ▌░ ▓██▓ ░ 
  ▒ ▓███▀ ░░▓█▒░██▓░▒████▒░▒████▓   ▒██▒ ░ 
  ░ ░▒ ▒  ░ ▒ ░░▒░▒░░ ▒░ ░ ▒▒▓  ▒   ▒ ░░   
    ░  ▒    ▒ ░▒░ ░ ░ ░  ░ ░ ▒  ▒     ░    
  ░         ░  ░░ ░   ░    ░ ░  ░   ░      
  ░ ░       ░  ░  ░   ░  ░   ░             
  ░                         ░             ${RESET}
"

# ========== 初始语言设置 ==========
LANGUAGE="CN"  # 默认中文

# ========== 多语言提示 ==========
function msg() {
  case "$1" in
    welcome)
      [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Welcome to the CHEAT VPS Initialization Toolkit!${RESET}" || echo -e "${GREEN}欢迎使用 CHEAT VPS 初始化工具！${RESET}"
      ;;
    warning)
      [[ $LANGUAGE == "EN" ]] && echo -e "${RED}⚠️  This script is for legal and trusted VPS setup only.${RESET}" || echo -e "${RED}⚠️  本脚本仅限用于受信任的 VPS 初始配置，请勿用于非法用途。${RESET}"
      ;;
    choose_lang)
      echo -e "1. 中文\n2. English"
      [[ $LANGUAGE == "EN" ]] && read -p "Please choose a language [1-2]: " choice || read -p "请选择语言 [1-2]: " choice
      [[ "$choice" == "2" ]] && LANGUAGE="EN"
      ;;
    root_warn)
      [[ $LANGUAGE == "EN" ]] && echo -e "${YELLOW}⚠️  Please run as root or with sudo to avoid permission issues.${RESET}" || echo -e "${YELLOW}⚠️  请使用 root 用户或加 sudo 执行脚本以避免权限问题。${RESET}"
      ;;
    return_menu)
      [[ $LANGUAGE == "EN" ]] && read -p "Press Enter to return to menu..." || read -p "按回车键返回主菜单..."
      ;;
  esac
}

# ========== 网络状态 ==========
check_network() {
  ping -c1 -W1 8.8.8.8 &>/dev/null && echo -e "${GREEN}在线${RESET}" || echo -e "${RED}离线${RESET}"
}

# ========== 权限检查 ==========
[[ $EUID -ne 0 ]] && msg root_warn

# ========== 主菜单 ==========
main_menu() {
  clear
  echo -e "$CHEAT_LOGO"
  msg welcome
  msg warning
  echo
  echo -e "${YELLOW}当前用户：$(whoami)   网络状态：$(check_network)${RESET}"
  echo
  echo -e "${BLUE}请选择一个操作：${RESET}"
  echo "1. 检测并修复主机名到 /etc/hosts"
  echo "2. 修复系统软件源并更新"
  echo "3. 清理系统缓存和垃圾"
  echo "4. 安装 WARP（第三方脚本）"
  echo "5. 一键安装 Docker"
  echo "6. VPS 性能测试"
  echo "7. 切换语言（当前语言：${LANGUAGE})"
  echo "8. 退出脚本"
  read -p "请输入选项 [1-8]: " opt

  case $opt in
    1) check_and_fix_hostname ;;
    2) fix_and_update_sources ;;
    3) clean_system_garbage ;;
    4) install_warp ;;
    5) install_docker ;;
    6) run_benchmark ;;
    7) msg choose_lang ;;
    8) exit_script ;;
    *) echo -e "${RED}无效输入！${RESET}" && sleep 1 ;;
  esac
  msg return_menu
  main_menu
}

# ========== 功能模块 ==========

check_and_fix_hostname() {
  echo -e "${BLUE}正在检测主机名...${RESET}"
  local hn=$(hostname)
  if grep -q "$hn" /etc/hosts; then
    echo -e "${GREEN}主机名 $hn 已存在于 /etc/hosts。${RESET}"
  else
    echo "127.0.0.1 $hn" >> /etc/hosts
    echo -e "${GREEN}已添加主机名 $hn 到 /etc/hosts。${RESET}"
  fi
}

fix_and_update_sources() {
  echo -e "${BLUE}正在检测并修复软件源...${RESET}"
  local os=""
  if [ -f /etc/debian_version ]; then
    os="debian"
  elif grep -qi ubuntu /etc/os-release; then
    os="ubuntu"
  elif grep -qi centos /etc/os-release; then
    os="centos"
  elif grep -qi almalinux /etc/os-release; then
    os="alma"
  fi

  case $os in
    debian|ubuntu)
      echo -e "${YELLOW}更新 apt 软件源...${RESET}"
      apt update && echo -e "${GREEN}软件源更新完成。${RESET}"
      read -p "是否安装系统更新？(y/n): " u
      [[ $u == y ]] && apt upgrade -y
      ;;
    centos|alma)
      echo -e "${YELLOW}更新 yum 软件源...${RESET}"
      yum makecache
      read -p "是否安装系统更新？(y/n): " u
      [[ $u == y ]] && yum update -y
      ;;
    *)
      echo -e "${RED}无法识别的系统。${RESET}"
      ;;
  esac
}

clean_system_garbage() {
  echo -e "${BLUE}正在清理系统缓存和垃圾...${RESET}"
  apt autoremove -y && apt clean && echo -e "${GREEN}清理完成。${RESET}"
}

install_warp() {
  echo -e "${BLUE}正在运行 WARP 安装脚本...${RESET}"
  bash <(wget -qO- https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh)
}

install_docker() {
  echo -e "${BLUE}正在安装 Docker...${RESET}"
  curl -fsSL https://get.docker.com | bash
  systemctl start docker
  systemctl enable docker
  echo -e "${GREEN}Docker 安装完成。${RESET}"
}

run_benchmark() {
  echo -e "${BLUE}正在运行 VPS 性能测试...${RESET}"
  curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
}

exit_script() {
  echo -e "${GREEN}感谢使用，欢迎下次再来！${RESET}"
  exit 0
}

# ========== 启动流程 ==========
msg choose_lang
main_menu
