#!/bin/bash

# ========= 色彩定义 =========
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
PURPLE="\033[35m"
RESET="\033[0m"

# ========= 兼容性检测 =========
SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)

# ========= 美化 LOGO =========
function print_logo() {
  if [ "$SUPPORT_UTF8" -eq 1 ]; then
    cat << "EOF"
${GREEN}
  ____ _               _   
 / ___| |__   ___  ___| |_ 
| |   | '_ \ / _ \/ __| __|
| |___| | | |  __/ (__| |_ 
 \____|_| |_|\___|\___|\__|
  
   CHEAT VPS TOOLKIT
${RESET}
EOF
  else
    echo -e "${GREEN}=== CHEAT VPS TOOLKIT ===${RESET}"
  fi
}

# ========= 多语言 =========
LANGUAGE="CN"

# 消息输出函数
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
    invalid)
      [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Invalid input!${RESET}" || echo -e "${RED}无效输入！${RESET}"
      ;;
  esac
}

# ========= 权限检测 =========
if [[ $EUID -ne 0 ]]; then
  msg root_warn
  exit 1
fi

# ========= 检测网络 =========
function check_network() {
  if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Network Status: Connected${RESET}" || echo -e "${GREEN}网络状态：已连接${RESET}"
  else
    [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Network Status: Disconnected${RESET}" || echo -e "${RED}网络状态：未连接${RESET}"
  fi
}

# ========= 基础功能 =========
fix_hostname() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${BLUE}Checking hostname...${RESET}"
  else
    echo -e "${BLUE}检测主机名...${RESET}"
  fi

  local hn=$(hostname)
  if grep -q "$hn" /etc/hosts; then
    [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Hostname exists in /etc/hosts${RESET}" || echo -e "${GREEN}主机名已存在 /etc/hosts${RESET}"
  else
    echo "127.0.0.1 $hn" >> /etc/hosts
    [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Added hostname to /etc/hosts${RESET}" || echo -e "${GREEN}添加主机名到 /etc/hosts${RESET}"
  fi
}

fix_sources() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${BLUE}Fixing package sources...${RESET}"
  else
    echo -e "${BLUE}修复软件源...${RESET}"
  fi

  if [ -f /etc/debian_version ]; then
    apt update && apt upgrade -y
  elif grep -qi centos /etc/os-release; then
    yum makecache && yum update -y
  else
    [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Unsupported system type${RESET}" || echo -e "${RED}暂不支持的系统类型${RESET}"
  fi
}

clean_garbage() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${BLUE}Cleaning cache...${RESET}"
  else
    echo -e "${BLUE}清理缓存...${RESET}"
  fi

  if command -v apt >/dev/null 2>&1; then
    apt autoremove -y && apt clean && echo -e "${GREEN}Done${RESET}"
  elif command -v yum >/dev/null 2>&1; then
    yum autoremove -y && yum clean all && echo -e "${GREEN}Done${RESET}"
  else
    [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Unknown package manager, cannot clean.${RESET}" || echo -e "${RED}未知包管理器，无法清理缓存${RESET}"
  fi
}

install_warp() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${BLUE}Installing WARP...${RESET}"
    echo -e "${YELLOW}Script source: https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh${RESET}"
  else
    echo -e "${BLUE}安装 WARP...${RESET}"
    echo -e "${YELLOW}脚本来源：https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh${RESET}"
  fi
  bash <(wget -qO- https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh)
}

install_docker() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${BLUE}Installing Docker...${RESET}"
  else
    echo -e "${BLUE}安装 Docker...${RESET}"
  fi
  curl -fsSL https://get.docker.com | bash
  systemctl enable docker --now
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${GREEN}Docker installed.${RESET}"
  else
    echo -e "${GREEN}Docker 已安装${RESET}"
  fi
}

run_benchmark() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${BLUE}Starting performance test...${RESET}"
    echo -e "${YELLOW}Performance test script source: https://run.NodeQuality.com${RESET}"
  else
    echo -e "${BLUE}开始性能测试...${RESET}"
    echo -e "${YELLOW}性能测试脚本来源：https://run.NodeQuality.com${RESET}"
  fi
  bash <(curl -sL https://run.NodeQuality.com) || {
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${RED}Performance test script failed to run.${RESET}"
    else
      echo -e "${RED}性能测试脚本运行失败。${RESET}"
    fi
  }
}

exit_script() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${GREEN}Thanks for using, bye!${RESET}"
  else
    echo -e "${GREEN}感谢使用，再见！${RESET}"
  fi
  exit 0
}

# ========= Swap 管理 =========
swap_manager() {
  while true; do
    clear
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== Swap Management ===${RESET}"
      echo "Current Swap status:"
    else
      echo -e "${GREEN}=== Swap 管理 ===${RESET}"
      echo "当前 Swap 状态："
    fi

    if swapon --show; then
      echo
    else
      [[ $LANGUAGE == "EN" ]] && echo -e "${YELLOW}No active Swap.${RESET}" || echo -e "${YELLOW}无启用 Swap。${RESET}"
    fi

    echo
    if [[ $LANGUAGE == "EN" ]]; then
      echo "1. Create/Modify Swap File"
      echo "2. Delete Swap File"
      echo "3. Return to Main Menu"
      read -p "Choose [1-3]: " sm_opt
    else
      echo "1. 创建/修改 Swap 文件"
      echo "2. 删除 Swap 文件"
      echo "3. 返回主菜单"
      read -p "请选择 [1-3]: " sm_opt
    fi

    case $sm_opt in
      1)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter swap size in GB (e.g. 2): " size_gb
        else
          read -p "请输入 Swap 大小（单位 GB，如 2）: " size_gb
        fi

        if ! [[ "$size_gb" =~ ^[0-9]+$ ]]; then
          [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Invalid size!${RESET}" || echo -e "${RED}无效大小！${RESET}"
          sleep 1
          continue
        fi

        swapoff -a
        rm -f /swapfile
        fallocate -l "${size_gb}G" /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile

        if ! grep -q '/swapfile' /etc/fstab; then
          echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi

        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Swap file created with size ${size_gb}G.${RESET}" || echo -e "${GREEN}Swap 文件创建成功，大小 ${size_gb}G。${RESET}"
        sleep 2
        ;;
      2)
        swapoff -a
        rm -f /swapfile
        sed -i '/\/swapfile/d' /etc/fstab
        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Swap file deleted.${RESET}" || echo -e "${GREEN}Swap 文件已删除。${RESET}"
        sleep 2
        ;;
      3)
        break
        ;;
      *)
        msg invalid
        sleep 1
        ;;
    esac
  done
}

# ========= 时间设置 =========
time_timezone() {
  while true; do
    clear
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== Timezone Settings ===${RESET}"
      echo "Select a timezone:"
      echo "1) Asia/Shanghai"
      echo "2) Asia/Tokyo"
      echo "3) Europe/London"
      echo "4) America/New_York"
      echo "5) Etc/UTC"
      echo "6) Enter manually"
      read -p "Choose [1-6]: " tz_choice
    else
      echo -e "${GREEN}=== 时间与时区设置 ===${RESET}"
      echo "请选择时区:"
      echo "1) 亚洲/上海 (Asia/Shanghai)"
      echo "2) 亚洲/东京 (Asia/Tokyo)"
      echo "3) 欧洲/伦敦 (Europe/London)"
      echo "4) 美洲/纽约 (America/New_York)"
      echo "5) 世界协调时 (Etc/UTC)"
      echo "6) 手动输入时区"
      read -p "请选择 [1-6]: " tz_choice
    fi

    case $tz_choice in
      1) tz="Asia/Shanghai" ;;
      2) tz="Asia/Tokyo" ;;
      3) tz="Europe/London" ;;
      4) tz="America/New_York" ;;
      5) tz="Etc/UTC" ;;
      6)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter timezone (e.g. Asia/Shanghai): " tz
        else
          read -p "请输入时区（例如 Asia/Shanghai）: " tz
        fi
        ;;
      *)
        msg invalid
        sleep 1
        continue
        ;;
    esac

    if [ -f /usr/share/zoneinfo/"$tz" ]; then
      ln -sf /usr/share/zoneinfo/"$tz" /etc/localtime
      hwclock --systohc
      [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Timezone set to $tz.${RESET}" || echo -e "${GREEN}时区已设置为 $tz。${RESET}"
      sleep 2
      break
    else
      [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Invalid timezone!${RESET}" || echo -e "${RED}无效的时区！${RESET}"
      sleep 2
    fi
  done
}

# ========= 用户管理 =========
user_manager() {
  while true; do
    clear
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== User Management ===${RESET}"
      echo "1) Add User"
      echo "2) Delete User"
      echo "3) Change Password"
      echo "4) Return"
      read -p "Choose [1-4]: " um_opt
    else
      echo -e "${GREEN}=== 用户管理 ===${RESET}"
      echo "1) 添加用户"
      echo "2) 删除用户"
      echo "3) 修改密码"
      echo "4) 返回"
      read -p "请选择 [1-4]: " um_opt
    fi

    case $um_opt in
      1)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter new username: " new_user
        else
          read -p "请输入新用户名: " new_user
        fi
        if id "$new_user" &>/dev/null; then
          [[ $LANGUAGE == "EN" ]] && echo -e "${YELLOW}User already exists.${RESET}" || echo -e "${YELLOW}用户已存在。${RESET}"
        else
          useradd -m "$new_user"
          passwd "$new_user"
          [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}User $new_user added.${RESET}" || echo -e "${GREEN}用户 $new_user 已添加。${RESET}"
        fi
        ;;
      2)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter username to delete: " del_user
        else
          read -p "请输入要删除的用户名: " del_user
        fi
        if id "$del_user" &>/dev/null; then
          userdel -r "$del_user"
          [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}User $del_user deleted.${RESET}" || echo -e "${GREEN}用户 $del_user 已删除。${RESET}"
        else
          [[ $LANGUAGE == "EN" ]] && echo -e "${YELLOW}User not found.${RESET}" || echo -e "${YELLOW}用户不存在。${RESET}"
        fi
        ;;
      3)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter username to change password: " pass_user
        else
          read -p "请输入用户名: " pass_user
        fi
        if id "$pass_user" &>/dev/null; then
          passwd "$pass_user"
          [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Password changed for $pass_user.${RESET}" || echo -e "${GREEN}用户 $pass_user 密码已修改。${RESET}"
        else
          [[ $LANGUAGE == "EN" ]] && echo -e "${YELLOW}User not found.${RESET}" || echo -e "${YELLOW}用户不存在。${RESET}"
        fi
        ;;
      4)
        break
        ;;
      *)
        msg invalid
        ;;
    esac
    msg return_menu
  done
}

# ========= 主菜单 =========
main_menu() {
  clear
  print_logo
  msg welcome
  msg warning
  echo

  echo -e "${PURPLE}=== System Information ===${RESET}"
  echo -e "Kernel: $(uname -r)"
  echo -e "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
  echo -e "Architecture: $(uname -m)"
  echo -e "User: $(whoami)"
  check_network
  echo

  if [[ $LANGUAGE == "EN" ]]; then
    echo "1) Fix Hostname and Sources"
    echo "2) Clean System Garbage"
    echo "3) Install WARP"
    echo "4) Install Docker"
    echo "5) Performance Test"
    echo "6) Swap Manager"
    echo "7) Security Settings"
    echo "8) Timezone Settings"
    echo "9) User Manager"
    echo "0) Exit"
    read -p "Choose function [0-9]: " opt
  else
    echo "1) 修复主机名和软件源"
    echo "2) 清理系统垃圾"
    echo "3) 安装 WARP"
    echo "4) 安装 Docker"
    echo "5) 性能测试"
    echo "6) Swap 管理"
    echo "7) 安全配置"
    echo "8) 时间与时区设置"
    echo "9) 用户管理"
    echo "0) 退出脚本"
    read -p "请选择功能 [0-9]: " opt
  fi

  case $opt in
    1)
      fix_hostname
      fix_sources
      ;;
    2)
      clean_garbage
      ;;
    3)
      install_warp
      ;;
    4)
      install_docker
      ;;
    5)
      run_benchmark
      ;;
    6)
      swap_manager
      ;;
    7)
      # 安全配置功能未提供示例，这里简单提示
      if [[ $LANGUAGE == "EN" ]]; then
        echo -e "${YELLOW}Security Settings module coming soon.${RESET}"
      else
        echo -e "${YELLOW}安全配置模块敬请期待。${RESET}"
      fi
      sleep 2
      ;;
    8)
      time_timezone
      ;;
    9)
      user_manager
      ;;
    0)
      exit_script
      ;;
    *)
      msg invalid
      ;;
  esac
  msg return_menu
}

# ========= 入口 =========
msg choose_lang

while true; do
  main_menu
done
