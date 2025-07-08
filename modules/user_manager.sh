#!/bin/bash
# modules/user_manager.sh - 用户管理模块

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)
ICON_INFO=$([ $SUPPORT_UTF8 -eq 1 ] && echo "👤" || echo "[USR]")
ICON_WARN=$([ $SUPPORT_UTF8 -eq 1 ] && echo "⚠️" || echo "[WARN]")
ICON_OK=$([ $SUPPORT_UTF8 -eq 1 ] && echo "✅" || echo "[OK]")

LOGFILE="/var/log/vps_user_manager.log"
touch $LOGFILE 2>/dev/null || LOGFILE="/tmp/vps_user_manager.log"

log() {
  echo "$(date '+%F %T') $1" >> "$LOGFILE"
}

list_users() {
  echo -e "${BLUE}${ICON_INFO} 当前系统用户列表：${RESET}"
  printf "%-15s %-8s %-10s\n" "用户名" "UID" "是否sudo"
  # 过滤系统用户，显示UID >= 1000，除去nobody
  awk -F: '($3 >= 1000) && ($1 != "nobody") {print $1, $3}' /etc/passwd | while read user uid; do
    if groups $user | grep -qw "sudo"; then
      sudo_status="是"
    else
      sudo_status="否"
    fi
    printf "%-15s %-8s %-10s\n" "$user" "$uid" "$sudo_status"
  done
  echo
}

add_user() {
  read -rp "请输入要添加的用户名: " newuser
  if id "$newuser" &>/dev/null; then
    echo -e "${RED}${ICON_WARN} 用户 $newuser 已存在！${RESET}"
    return
  fi
  read -rp "请输入用户密码: " -s passwd1
  echo
  read -rp "请再次输入密码确认: " -s passwd2
  echo
  if [[ "$passwd1" != "$passwd2" ]]; then
    echo -e "${RED}${ICON_WARN} 两次密码输入不一致！${RESET}"
    return
  fi
  echo "请选择用户权限："
  select perm in "普通用户" "sudo用户" "取消"; do
    case $perm in
      普通用户)
        useradd -m "$newuser" && echo "$newuser:$passwd1" | chpasswd
        echo -e "${GREEN}${ICON_OK} 用户 $newuser 添加成功（普通用户）${RESET}"
        log "添加普通用户 $newuser"
        break
        ;;
      sudo用户)
        useradd -m -G sudo "$newuser" && echo "$newuser:$passwd1" | chpasswd
        echo -e "${GREEN}${ICON_OK} 用户 $newuser 添加成功（sudo用户）${RESET}"
        log "添加sudo用户 $newuser"
        break
        ;;
      取消) break ;;
      *) echo "无效选择，请重试。" ;;
    esac
  done
}

del_user() {
  read -rp "请输入要删除的用户名: " deluser
  if ! id "$deluser" &>/dev/null; then
    echo -e "${RED}${ICON_WARN} 用户 $deluser 不存在！${RESET}"
    return
  fi
  read -rp "确认删除用户 $deluser 及其主目录？(y/n): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    userdel -r "$deluser"
    echo -e "${GREEN}${ICON_OK} 用户 $deluser 已删除${RESET}"
    log "删除用户 $deluser"
  else
    echo "取消删除。"
  fi
}

main_menu() {
  clear
  echo -e "${GREEN}=== 用户管理模块 ===${RESET}"
  echo
  list_users
  echo "请选择操作："
  echo "1) 添加用户"
  echo "2) 删除用户"
  echo "3) 查看用户列表"
  echo "0) 返回主菜单"
  read -rp "请输入选项: " choice
  case $choice in
    1) add_user ;;
    2) del_user ;;
    3) list_users ;;
    0) exit 0 ;;
    *) echo -e "${RED}${ICON_WARN} 无效选择${RESET}" ;;
  esac
  read -rp "按回车返回菜单..."
  main_menu
}

main_menu
