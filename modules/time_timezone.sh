#!/bin/bash
# modules/time_timezone.sh - 系统时间与时区配置模块

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)
ICON_INFO=$([ $SUPPORT_UTF8 -eq 1 ] && echo "🕒" || echo "[TIME]")
ICON_WARN=$([ $SUPPORT_UTF8 -eq 1 ] && echo "⚠️" || echo "[WARN]")
ICON_OK=$([ $SUPPORT_UTF8 -eq 1 ] && echo "✅" || echo "[OK]")

LOGFILE="/var/log/vps_time_timezone.log"
touch $LOGFILE 2>/dev/null || LOGFILE="/tmp/vps_time_timezone.log"

backup_file="/etc/timezone.bak"

log() {
  echo "$(date '+%F %T') $1" >> "$LOGFILE"
}

backup_timezone() {
  if [ ! -f "$backup_file" ]; then
    cp /etc/timezone "$backup_file" 2>/dev/null
    log "备份当前时区配置"
  fi
}

show_current_time() {
  echo -e "${BLUE}${ICON_INFO} 当前系统时间：$(date '+%F %T %Z')${RESET}"
  echo -e "${BLUE}${ICON_INFO} 当前时区配置文件 /etc/timezone 内容："
  cat /etc/timezone
}

list_common_zones() {
  echo -e "${GREEN}常用热门时区列表：${RESET}"
  echo "1) Asia/Shanghai (中国标准时间)"
  echo "2) Asia/Tokyo (日本)"
  echo "3) Asia/Kolkata (印度)"
  echo "4) Europe/London (伦敦)"
  echo "5) Europe/Berlin (柏林)"
  echo "6) America/New_York (纽约)"
  echo "7) America/Los_Angeles (洛杉矶)"
  echo "8) Australia/Sydney (悉尼)"
  echo "9) 手动输入时区"
  echo "10) 恢复原时区"
  echo "0) 退出"
}

validate_timezone() {
  local tz=$1
  if [ -f "/usr/share/zoneinfo/$tz" ]; then
    return 0
  else
    return 1
  fi
}

set_timezone() {
  local tz=$1
  if validate_timezone "$tz"; then
    timedatectl set-timezone "$tz" 2>/dev/null || {
      echo "$tz" > /etc/timezone
      ln -sf "/usr/share/zoneinfo/$tz" /etc/localtime
    }
    echo -e "${GREEN}${ICON_OK} 时区已设置为 $tz${RESET}"
    log "时区设置为 $tz"
  else
    echo -e "${RED}${ICON_WARN} 时区无效或不存在：$tz${RESET}"
  fi
}

restore_timezone() {
  if [ -f "$backup_file" ]; then
    local old_tz=$(cat "$backup_file")
    set_timezone "$old_tz"
    echo -e "${GREEN}${ICON_OK} 已恢复原时区：$old_tz${RESET}"
    log "恢复时区到 $old_tz"
  else
    echo -e "${YELLOW}${ICON_WARN} 无备份文件，无法恢复原时区${RESET}"
  fi
}

usage() {
  echo -e "时间与时区配置脚本
用法：
  $0              # 交互菜单
  $0 --set-zone Asia/Shanghai   # 直接设置时区
  $0 --show                    # 显示当前时间和时区
  $0 --restore                 # 恢复原时区
"
}

# 处理命令行参数
if [[ "$1" == "--set-zone" && -n "$2" ]]; then
  backup_timezone
  set_timezone "$2"
  exit 0
elif [[ "$1" == "--show" ]]; then
  show_current_time
  exit 0
elif [[ "$1" == "--restore" ]]; then
  restore_timezone
  exit 0
elif [[ "$1" == "--help" ]]; then
  usage
  exit 0
fi

# 交互菜单
backup_timezone
while true; do
  show_current_time
  echo
  list_common_zones
  read -rp "请选择时区编号或操作 (0退出): " choice
  case $choice in
    1) set_timezone "Asia/Shanghai" ;;
    2) set_timezone "Asia/Tokyo" ;;
    3) set_timezone "Asia/Kolkata" ;;
    4) set_timezone "Europe/London" ;;
    5) set_timezone "Europe/Berlin" ;;
    6) set_timezone "America/New_York" ;;
    7) set_timezone "America/Los_Angeles" ;;
    8) set_timezone "Australia/Sydney" ;;
    9)
      read -rp "请输入时区（如 Asia/Shanghai）: " manual_tz
      set_timezone "$manual_tz"
      ;;
    10) restore_timezone ;;
    0) break ;;
    *) echo -e "${RED}${ICON_WARN} 无效选择，请重试${RESET}" ;;
  esac
done
