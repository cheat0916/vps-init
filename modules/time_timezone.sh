#!/bin/bash
# modules/time_timezone.sh - 系统时间与时区配置模块

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)
ICON_INFO=$([ $SUPPORT_UTF8 -eq 1 ] && echo "⏰" || echo "[TIME]")
ICON_OK=$([ $SUPPORT_UTF8 -eq 1 ] && echo "✅" || echo "[OK]")
ICON_WARN=$([ $SUPPORT_UTF8 -eq 1 ] && echo "⚠️" || echo "[WARN]")

LOGFILE="/var/log/vps_time_timezone.log"
touch "$LOGFILE" 2>/dev/null || LOGFILE="/tmp/vps_time_timezone.log"

log() {
  echo "$(date '+%F %T') $1" >> "$LOGFILE"
}

backup_timezone() {
  if [ ! -f /etc/localtime.bak ]; then
    cp /etc/localtime /etc/localtime.bak 2>/dev/null
    [ -f /etc/timezone ] && cp /etc/timezone /etc/timezone.bak 2>/dev/null
    log "备份时区配置"
  fi
}

restore_timezone() {
  if [ -f /etc/localtime.bak ]; then
    cp /etc/localtime.bak /etc/localtime
    [ -f /etc/timezone.bak ] && cp /etc/timezone.bak /etc/timezone
    echo -e "${GREEN}${ICON_OK} 已恢复之前备份的时区配置${RESET}"
    log "恢复时区配置"
  else
    echo -e "${RED}${ICON_WARN} 没有找到备份的时区配置${RESET}"
  fi
}

list_common_timezones() {
  echo -e "${BLUE}${ICON_INFO} 常用时区列表：${RESET}"
  echo "1) Asia/Shanghai (北京时间)"
  echo "2) Asia/Tokyo (东京)"
  echo "3) Asia/Kolkata (印度标准时间)"
  echo "4) Europe/London (伦敦)"
  echo "5) Europe/Paris (巴黎)"
  echo "6) America/New_York (纽约)"
  echo "7) America/Los_Angeles (洛杉矶)"
  echo "8) UTC (协调世界时)"
  echo "9) 其他（手动输入）"
  echo "0) 恢复之前备份时区"
}

set_timezone() {
  local tz="$1"
  if [ ! -f "/usr/share/zoneinfo/$tz" ]; then
    echo -e "${RED}${ICON_WARN} 时区无效或不存在：$tz${RESET}"
    return 1
  fi
  cp /usr/share/zoneinfo/"$tz" /etc/localtime
  echo "$tz" > /etc/timezone 2>/dev/null || true
  log "设置时区为 $tz"
  echo -e "${GREEN}${ICON_OK} 时区已设置为 $tz${RESET}"
}

input_timezone() {
  read -rp "请输入时区名称 (如 Asia/Shanghai): " tz_input
  set_timezone "$tz_input"
}

main_menu() {
  clear
  echo -e "${GREEN}=== 系统时间与时区配置 ===${RESET}"
  backup_timezone
  list_common_timezones
  read -rp "请选择操作 [0-9]: " choice
  case $choice in
    1) set_timezone "Asia/Shanghai" ;;
    2) set_timezone "Asia/Tokyo" ;;
    3) set_timezone "Asia/Kolkata" ;;
    4) set_timezone "Europe/London" ;;
    5) set_timezone "Europe/Paris" ;;
    6) set_timezone "America/New_York" ;;
    7) set_timezone "America/Los_Angeles" ;;
    8) set_timezone "UTC" ;;
    9) input_timezone ;;
    0) restore_timezone ;;
    *) echo -e "${RED}${ICON_WARN} 无效输入${RESET}" ;;
  esac
  read -rp "按回车返回菜单..."
  main_menu
}

main_menu
