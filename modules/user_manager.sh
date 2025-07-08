#!/bin/bash
# modules/user_manager.sh - 用户管理模块

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)
ICON_USER=$([ $SUPPORT_UTF8 -eq 1 ] && echo "👤" || echo "[USER]")
ICON_OK=$([ $SUPPORT_UTF8 -eq 1 ] && echo "✅" || echo "[OK]")
ICON_WARN=$([ $SUPPORT_UTF8 -eq 1 ] && echo "⚠️" || echo "[WARN]")

LOGFILE="/var/log/vps_user.log"
touch "$LOGFILE" 2>/dev/null || LOGFILE="/tmp/vps_user.log"

log() {
  echo "$(date '+%F %T') $1" >> "$LOGFILE"
}

list_users() {
  echo -e "${BLUE}${ICON_USER} 当前非系统用户列表:${RESET}"
  awk -F: '$3 >= 1000 && $1 != "nobody" {print "- " $1 " (" $3 ")"}' /etc/passwd
}

add_user() {
  read -rp "请输入要添加的用户名: " username
  if id "$username" &>/dev/null; then
    echo -e "${RED}用户 $username 已存在${RESET}"
    return
  fi
  useradd -m "$username"
  read -s -rp "设置用户密码: " pwd1
  echo
  read -s -rp "再次确认密码: " pwd2
  echo
  [[ "$pwd1" != "$pwd2" ]] && echo -e "${RED}密码不一致，取消添加${RESET}" && return
  echo "$username:$pwd1" | chpasswd
  read -rp "是否授予 sudo 权限？(y/n): " sudo_flag
  [[ "$sudo_flag" == "y" ]] && usermod -aG sudo "$username"
  echo -e "${GREEN}${ICON_OK} 用户 $username 添加成功${RESET}"
  log "添加用户 $username，sudo: $sudo_flag"
}

del_user() {
  read -rp "请输入要删除的用户名: " username
  if ! id "$username" &>/dev/null; then
    echo -e "${RED}用户 $username 不存在${RESET}"
    return
  fi
  read -rp "是否删除用户主目录？(y/n): " del_home
  if [[ "$del_home" == "y" ]]; then
    userdel -r "$username"
    log "删除用户 $username（含主目录）"
  else
    userdel "$username"
    log "删除用户 $username（保留主目录）"
  fi
  echo -e "${YELLOW}${ICON_WARN} 用户 $username 已删除${RESET}"
}

change_pass() {
  read -rp "请输入要修改密码的用户名: " username
  if ! id "$username" &>/dev/null; then
    echo -e "${RED}用户不存在${RESET}"
    return
  fi
  passwd "$username"
  log "修改用户 $username 密码"
}

toggle_sudo() {
  read -rp "请输入用户名: " username
  if ! id "$username" &>/dev/null; then
    echo -e "${RED}用户不存在${RESET}"
    return
  fi
  if groups "$username" | grep -q '\bsudo\b'; then
    deluser "$username" sudo
    echo -e "${YELLOW}已移除 $username 的 sudo 权限${RESET}"
    log "移除 sudo 权限：$username"
  else
    usermod -aG sudo "$username"
    echo -e "${GREEN}已授予 $username sudo 权限${RESET}"
    log "授予 sudo 权限：$username"
  fi
}

main_menu() {
  clear
  echo -e "${GREEN}=== 用户管理模块 ===${RESET}"
  echo "1) 查看所有用户"
  echo "2) 添加新用户"
  echo "3) 删除用户"
  echo "4) 修改用户密码"
  echo "5) 切换用户 sudo 权限"
  echo "0) 返回主菜单"
  read -rp "请输入选项 [0-5]: " choice
  case $choice in
    1) list_users ;;
    2) add_user ;;
    3) del_user ;;
    4) change_pass ;;
    5) toggle_sudo ;;
    0) return ;;
    *) echo -e "${RED}无效输入${RESET}" ;;
  esac
  read -rp "按回车继续..."
  main_menu
}

main_menu
