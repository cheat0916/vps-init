#!/bin/bash

# ========= 色彩定义 =========
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

# ========= 兼容性检测 =========
SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)

# ========= LOGO =========
if [ "$SUPPORT_UTF8" -eq 1 ]; then
  CHEAT_LOGO="${GREEN}=== 🧠 CHEAT VPS TOOLKIT ===${RESET}"
else
  CHEAT_LOGO="${GREEN}=== CHEAT VPS TOOLKIT ===${RESET}"
fi

# ========= 多语言初始化 =========
LANGUAGE="CN"
function msg() {
  case "$1" in
    welcome)
      [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Welcome to the CHEAT VPS Initialization Toolkit!${RESET}" || echo -e "${GREEN}欢迎使用 CHEAT VPS 初始化工具！${RESET}"
      ;;
    warning)
      [[ $LANGUAGE == "EN" ]] && echo -e "${RED}⚠️  Legal VPS setup only.${RESET}" || echo -e "${RED}⚠️  本脚本仅限合法用途，请勿用于非法行为。${RESET}"
      ;;
    choose_lang)
      echo -e "1. 中文\n2. English"
      [[ $LANGUAGE == "EN" ]] && read -p "Choose language [1-2]: " choice || read -p "请选择语言 [1-2]: " choice
      [[ "$choice" == "2" ]] && LANGUAGE="EN"
      ;;
    root_warn)
      [[ $LANGUAGE == "EN" ]] && echo -e "${YELLOW}⚠️  Please run as root or with sudo.${RESET}" || echo -e "${YELLOW}⚠️  请使用 root 用户或 sudo 执行。${RESET}"
      ;;
    return_menu)
      [[ $LANGUAGE == "EN" ]] && read -p "Press Enter to return..." || read -p "按回车键返回..."
      ;;
  esac
}

# ========= 权限检测 =========
[[ $EUID -ne 0 ]] && msg root_warn

# ========= 主菜单 =========
main_menu() {
  clear
  echo -e "$CHEAT_LOGO"
  msg welcome
  msg warning
  echo
  echo -e "${YELLOW}当前用户：$(whoami)   网络：$(ping -c1 -W1 1.1.1.1 >/dev/null 2>&1 && echo 在线 || echo 离线)${RESET}"
  echo
  echo -e "${BLUE}请选择操作：${RESET}"
  echo "1. 修复主机名 /etc/hosts"
  echo "2. 修复软件源并更新"
  echo "3. 清理系统垃圾"
  echo "4. 安装 WARP"
  echo "5. 安装 Docker"
  echo "6. VPS 性能测试"
  echo "7. Swap 管理"
  echo "8. 安全配置（SSH、防火墙、Fail2Ban）"
  echo "9. 系统时间与时区配置"
  echo "10. 用户管理"
  echo "11. 切换语言（当前：${LANGUAGE})"
  echo "12. 退出"
  read -p "请输入选项 [1-12]: " opt

  case $opt in
    1) fix_hostname ;;
    2) fix_sources ;;
    3) clean_garbage ;;
    4) install_warp ;;
    5) install_docker ;;
    6) run_benchmark ;;
    7) bash modules/swap_manager.sh ;;
    8) bash modules/security_config.sh ;;
    9) bash modules/time_timezone.sh ;;
    10) bash modules/user_manager.sh ;;
    11) msg choose_lang ;;
    12) exit_script ;;
    *) echo -e "${RED}无效输入！${RESET}" && sleep 1 ;;
  esac
  msg return_menu
  main_menu
}

# ========= 基础功能 =========
fix_hostname() {
  echo -e "${BLUE}检测主机名...${RESET}"
  local hn=$(hostname)
  if grep -q "$hn" /etc/hosts; then
    echo -e "${GREEN}主机名已存在 /etc/hosts${RESET}"
  else
    echo "127.0.0.1 $hn" >> /etc/hosts
    echo -e "${GREEN}添加主机名到 /etc/hosts${RESET}"
  fi
}

fix_sources() {
  echo -e "${BLUE}修复软件源...${RESET}"
  if [ -f /etc/debian_version ]; then
    apt update && apt upgrade -y
  elif grep -qi centos /etc/os-release; then
    yum makecache && yum update -y
  else
    echo -e "${RED}暂不支持的系统类型${RESET}"
  fi
}

clean_garbage() {
  echo -e "${BLUE}清理缓存...${RESET}"
  apt autoremove -y && apt clean && echo -e "${GREEN}完成${RESET}"
}

install_warp() {
  echo -e "${BLUE}安装 WARP...${RESET}"
  bash <(wget -qO- https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh)
}

install_docker() {
  echo -e "${BLUE}安装 Docker...${RESET}"
  curl -fsSL https://get.docker.com | bash
  systemctl enable docker --now
  echo -e "${GREEN}Docker 已安装${RESET}"
}

run_benchmark() {
  echo -e "${BLUE}运行性能测试...${RESET}"
  curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
}

exit_script() {
  echo -e "${GREEN}感谢使用，再见！${RESET}"
  exit 0
}

# ========= 启动 =========
msg choose_lang
main_menu
