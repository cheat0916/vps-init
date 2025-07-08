#!/bin/bash
# VPS管理脚本示例，支持中英文切换、时间设置、swap管理

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
RESET='\033[0m'

# 默认语言，支持 EN 或 CN
LANGUAGE="CN"

# 通用提示函数
msg() {
  case "$1" in
    welcome)
      [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Welcome to VPS Management Script${RESET}" || echo -e "${GREEN}欢迎使用 VPS 管理脚本${RESET}"
      ;;
    warning)
      [[ $LANGUAGE == "EN" ]] && echo -e "${YELLOW}Please run as root and check your network connection.${RESET}" || echo -e "${YELLOW}请确保以 root 身份运行并确认网络连接正常。${RESET}"
      ;;
    invalid)
      [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Invalid input, please try again.${RESET}" || echo -e "${RED}输入无效，请重试。${RESET}"
      ;;
    return_menu)
      [[ $LANGUAGE == "EN" ]] && echo -e "${YELLOW}Returning to main menu...${RESET}" || echo -e "${YELLOW}返回主菜单...${RESET}"
      sleep 1
      ;;
  esac
}

# 打印简单LOGO
print_logo() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${PURPLE}
  __   __   ___    _____
  \\ \\ / /  / _ \\  | ____|
   \\ V /  | | | | |  _|
    | |   | |_| | | |___
    |_|    \\___/  |_____|
${RESET}"
  else
    echo -e "${PURPLE}
  __   __   ___    _____
  \\ \\ / /  / _ \\  | ____|
   \\ V /  | | | | |  _|
    | |   | |_| | | |___
    |_|    \\___/  |_____|
  VPS 管理脚本
${RESET}"
  fi
}

# 检查网络连接
check_network() {
  if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
    [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Network: Connected${RESET}" || echo -e "${GREEN}网络状态：已连接${RESET}"
  else
    [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Network: Disconnected${RESET}" || echo -e "${RED}网络状态：未连接${RESET}"
  fi
}

# 主菜单
main_menu() {
  while true; do
    clear
    print_logo
    msg welcome
    msg warning
    echo

    echo -e "${PURPLE}=== $( [[ $LANGUAGE == 'EN' ]] && echo 'System Information' || echo '系统信息' ) ===${RESET}"

    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "Kernel: $(uname -r)"
      echo -e "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
      echo -e "Architecture: $(uname -m)"
      echo -e "User: $(whoami)"
    else
      echo -e "内核版本: $(uname -r)"
      echo -e "操作系统: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
      echo -e "系统架构: $(uname -m)"
      echo -e "当前用户: $(whoami)"
    fi

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
      echo "10) Language Switch"
      echo "0) Exit"
      read -p "Choose function [0-10]: " opt
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
      echo "10) 切换语言"
      echo "0) 退出脚本"
      read -p "请选择功能 [0-10]: " opt
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
      10)
        language_switch
        ;;
      0)
        exit_script
        ;;
      *)
        msg invalid
        ;;
    esac
  done
}

# 语言切换
language_switch() {
  clear
  echo "1) 中文"
  echo "2) English"
  read -p "Select language / 选择语言 [1-2]: " lang_sel
  case $lang_sel in
    1) LANGUAGE="CN" ;;
    2) LANGUAGE="EN" ;;
    *) msg invalid; sleep 1 ;;
  esac
}

# 时间与时区设置
time_timezone() {
  while true; do
    clear
    current_tz=$(cat /etc/timezone 2>/dev/null || timedatectl | grep "Time zone" | awk '{print $3}')
    current_time=$(date +"%Y-%m-%d %H:%M:%S")
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== Timezone Settings ===${RESET}"
      echo "Current timezone: $current_tz"
      echo "Current time: $current_time"
      echo
      echo "Select a timezone:"
      echo "1) Asia/Shanghai"
      echo "2) Asia/Tokyo"
      echo "3) Europe/London"
      echo "4) America/New_York"
      echo "5) Etc/UTC"
      echo "6) Enter manually"
      echo "0) Return"
      read -p "Choose [0-6]: " tz_choice
    else
      echo -e "${GREEN}=== 时间与时区设置 ===${RESET}"
      echo "当前时区: $current_tz"
      echo "当前时间: $current_time"
      echo
      echo "请选择时区:"
      echo "1) 亚洲/上海 (Asia/Shanghai)"
      echo "2) 亚洲/东京 (Asia/Tokyo)"
      echo "3) 欧洲/伦敦 (Europe/London)"
      echo "4) 美洲/纽约 (America/New_York)"
      echo "5) 世界协调时 (Etc/UTC)"
      echo "6) 手动输入时区"
      echo "0) 返回"
      read -p "请选择 [0-6]: " tz_choice
    fi

    case $tz_choice in
      0)
        break
        ;;
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
      echo "$tz" >/etc/timezone
      hwclock --systohc
      if [[ $LANGUAGE == "EN" ]]; then
        echo -e "${GREEN}Timezone set to $tz.${RESET}"
      else
        echo -e "${GREEN}时区已设置为 $tz。${RESET}"
      fi
      sleep 2
      break
    else
      if [[ $LANGUAGE == "EN" ]]; then
        echo -e "${RED}Invalid timezone!${RESET}"
      else
        echo -e "${RED}无效的时区！${RESET}"
      fi
      sleep 2
    fi
  done
}

# Swap 管理
swap_manager() {
  while true; do
    clear

    swap_total=$(free -m | awk '/Swap:/ {print $2}')
    swap_used=$(free -m | awk '/Swap:/ {print $3}')
    swap_free=$(free -m | awk '/Swap:/ {print $4}')
    mem_total=$(free -m | awk '/Mem:/ {print $2}')
    disk_root=$(df -h / | awk 'NR==2 {print $2}')
    disk_avail=$(df -h / | awk 'NR==2 {print $4}')

    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== Swap Manager ===${RESET}"
      echo "Total RAM: ${mem_total} MB"
      echo "Root Disk Size: ${disk_root}"
      echo "Available Disk Space: ${disk_avail}"
      if [[ $swap_total -gt 0 ]]; then
        echo "Current Swap: ${swap_total} MB (Used: ${swap_used} MB, Free: ${swap_free} MB)"
      else
        echo "Swap is currently disabled."
      fi
      recommend_swap=$(( mem_total * 2 ))
      echo "Recommended swap size: ${recommend_swap} MB (usually 1-2x RAM)"
      echo
      echo "1) Create/Resize Swap"
      echo "2) Delete Swap"
      echo "0) Return"
      read -p "Choose option [0-2]: " swap_choice
    else
      echo -e "${GREEN}=== Swap 管理 ===${RESET}"
      echo "内存总量: ${mem_total} MB"
      echo "根分区磁盘大小: ${disk_root}"
      echo "可用磁盘空间: ${disk_avail}"
      if [[ $swap_total -gt 0 ]]; then
        echo "当前 Swap: ${swap_total} MB (已用: ${swap_used} MB, 空闲: ${swap_free} MB)"
      else
        echo "当前未启用 Swap。"
      fi
      recommend_swap=$(( mem_total * 2 ))
      echo "建议 Swap 大小: ${recommend_swap} MB （一般为内存大小的1-2倍）"
      echo
      echo "1) 创建/调整 Swap"
      echo "2) 删除 Swap"
      echo "0) 返回"
      read -p "请选择 [0-2]: " swap_choice
    fi

    case $swap_choice in
      0)
        break
        ;;
      1)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter swap size in MB (e.g. 2048): " size_mb
        else
          read -p "请输入 Swap 大小（单位 MB，例如 2048）: " size_mb
        fi

        if ! [[ "$size_mb" =~ ^[0-9]+$ ]]; then
          [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Invalid size!${RESET}" || echo -e "${RED}无效大小！${RESET}"
          sleep 1
          continue
        fi

        swapoff -a
        rm -f /swapfile
        fallocate -l "${size_mb}M" /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile

        if ! grep -q '/swapfile' /etc/fstab; then
          echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi

        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Swap file created with size ${size_mb} MB.${RESET}" || echo -e "${GREEN}Swap 文件创建成功，大小 ${size_mb} MB。${RESET}"
        sleep 2
        ;;
      2)
        swapoff -a
        rm -f /swapfile
        sed -i '/\/swapfile/d' /etc/fstab
        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Swap file deleted.${RESET}" || echo -e "${GREEN}Swap 文件已删除。${RESET}"
        sleep 2
        ;;
      *)
        msg invalid
        sleep 1
        ;;
    esac
  done
}

# 退出脚本
exit_script() {
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${GREEN}Thank you for using the VPS Management Script. Goodbye!${RESET}"
  else
    echo -e "${GREEN}感谢使用 VPS 管理脚本，再见！${RESET}"
  fi
  exit 0
}

# 以下为示例占位函数
fix_hostname() {
  [[ $LANGUAGE == "EN" ]] && echo "Fixing hostname..." || echo "修复主机名..."
  sleep 1
}

fix_sources() {
  [[ $LANGUAGE == "EN" ]] && echo "Fixing software sources..." || echo "修复软件源..."
  sleep 1
}

clean_garbage() {
  [[ $LANGUAGE == "EN" ]] && echo "Cleaning system garbage..." || echo "清理系统垃圾..."
  sleep 1
}

install_warp() {
  [[ $LANGUAGE == "EN" ]] && echo "Installing WARP..." || echo "安装 WARP..."
  sleep 1
}

install_docker() {
  [[ $LANGUAGE == "EN" ]] && echo "Installing Docker..." || echo "安装 Docker..."
  sleep 1
}

run_benchmark() {
  [[ $LANGUAGE == "EN" ]] && echo "Running performance test..." || echo "运行性能测试..."
  sleep 1
}

user_manager() {
  [[ $LANGUAGE == "EN" ]] && echo "User management module..." || echo "用户管理模块..."
  sleep 1
}

# 入口
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}Please run this script as root.${RESET}"
  exit 1
fi

main_menu
