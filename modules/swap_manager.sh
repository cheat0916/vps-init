#!/bin/bash
# modules/swap_manager.sh - Swap 管理模块
# 支持查看、添加、删除 swap，兼容美化，支持交互及命令行参数

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)
ICON_INFO=$([ $SUPPORT_UTF8 -eq 1 ] && echo "💾" || echo "[INFO]")
ICON_WARN=$([ $SUPPORT_UTF8 -eq 1 ] && echo "⚠️" || echo "[WARN]")
ICON_OK=$([ $SUPPORT_UTF8 -eq 1 ] && echo "✅" || echo "[OK]")

LOGFILE="/var/log/vps_swap_manager.log"
touch $LOGFILE 2>/dev/null || LOGFILE="/tmp/vps_swap_manager.log"

log() {
  echo "$(date '+%F %T') $1" >> "$LOGFILE"
}

show_swap() {
  echo -e "${BLUE}${ICON_INFO} 当前 Swap 使用情况：${RESET}"
  swapon --show
  free -h | grep Swap
}

add_swap() {
  local size=$1
  if [[ ! $size =~ ^[0-9]+[GgMm]$ ]]; then
    echo -e "${RED}${ICON_WARN} 请输入合法的Swap大小，如2G或512M${RESET}"
    return 1
  fi
  if swapon --show | grep -q "/swapfile"; then
    echo -e "${YELLOW}${ICON_WARN} 系统已存在 /swapfile，若要重新创建请先删除旧swap。${RESET}"
    return 1
  fi

  echo -e "${BLUE}${ICON_INFO} 创建 ${size} 大小的 swap 文件 /swapfile ...${RESET}"
  fallocate -l $size /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=$(echo $size | sed -E 's/([0-9]+).*/\1/') 2>/dev/null
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile

  if swapon --show | grep -q "/swapfile"; then
    echo -e "${GREEN}${ICON_OK} Swap添加成功！${RESET}"
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
    log "添加Swap文件，大小: $size"
    return 0
  else
    echo -e "${RED}${ICON_WARN} Swap添加失败！${RESET}"
    return 1
  fi
}

del_swap() {
  if swapon --show | grep -q "/swapfile"; then
    echo -e "${BLUE}${ICON_INFO} 正在关闭并删除 /swapfile ...${RESET}"
    swapoff /swapfile
    sed -i '/\/swapfile/d' /etc/fstab
    rm -f /swapfile
    echo -e "${GREEN}${ICON_OK} Swap已删除${RESET}"
    log "删除Swap文件"
  else
    echo -e "${YELLOW}${ICON_WARN} 当前无 /swapfile Swap可删除${RESET}"
  fi
}

usage() {
  echo -e "Swap 管理脚本
用法：
  $0              # 交互菜单模式
  $0 --setup-swap 2G  # 直接添加2G Swap
  $0 --del-swap       # 删除Swap
  $0 --show           # 查看当前Swap状态
"
}

# 支持命令行参数运行
if [[ "$1" == "--setup-swap" ]]; then
  if [[ -z "$2" ]]; then
    echo -e "${RED}${ICON_WARN} 缺少Swap大小参数${RESET}"
    usage
    exit 1
  fi
  add_swap "$2"
  exit $?
elif [[ "$1" == "--del-swap" ]]; then
  del_swap
  exit 0
elif [[ "$1" == "--show" ]]; then
  show_swap
  exit 0
fi

# 交互菜单
while true; do
  echo -e "\n${GREEN}=== Swap 管理菜单 ===${RESET}"
  echo "1) 查看当前 Swap"
  echo "2) 添加 Swap 文件"
  echo "3) 删除 Swap 文件"
  echo "4) 退出"
  read -rp "请选择操作 [1-4]: " choice
  case $choice in
    1) show_swap ;;
    2)
      read -rp "请输入Swap大小 (如2G, 512M): " size
      add_swap "$size"
      ;;
    3) del_swap ;;
    4) break ;;
    *) echo -e "${RED}${ICON_WARN} 无效选择，请重试${RESET}" ;;
  esac
done
