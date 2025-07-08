#!/bin/bash
# modules/security_config.sh - 安全配置模块

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)
ICON_LOCK=$([ $SUPPORT_UTF8 -eq 1 ] && echo "🔒" || echo "[LOCK]")
ICON_OK=$([ $SUPPORT_UTF8 -eq 1 ] && echo "✅" || echo "[OK]")
ICON_WARN=$([ $SUPPORT_UTF8 -eq 1 ] && echo "⚠️" || echo "[WARN]")

LOGFILE="/var/log/vps_security.log"
touch "$LOGFILE" 2>/dev/null || LOGFILE="/tmp/vps_security.log"

log() {
  echo "$(date '+%F %T') $1" >> "$LOGFILE"
}

backup_sshd() {
  [ ! -f /etc/ssh/sshd_config.bak ] && cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
}

restart_ssh() {
  systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
}

set_ssh_port() {
  read -rp "请输入新的 SSH 端口（建议大于1024）: " newport
  if [[ "$newport" =~ ^[0-9]+$ ]] && [ "$newport" -ge 22 ] && [ "$newport" -le 65535 ]; then
    sed -i "s/^#Port .*/Port $newport/" /etc/ssh/sshd_config
    sed -i "s/^Port .*/Port $newport/" /etc/ssh/sshd_config
    echo -e "${GREEN}${ICON_OK} SSH 端口已设置为 $newport${RESET}"
    log "设置 SSH 端口为 $newport"
    restart_ssh
  else
    echo -e "${RED}${ICON_WARN} 输入无效${RESET}"
  fi
}

toggle_ssh_option() {
  local option=$1
  local desc=$2
  local current=$(grep -Ei "^$option" /etc/ssh/sshd_config | awk '{print $2}')
  echo -e "${BLUE}${ICON_LOCK} 当前 $desc：$current${RESET}"
  read -rp "是否修改为 no？(y/n): " yn
  if [[ "$yn" == "y" ]]; then
    sed -i "s/^#*$option .*/$option no/" /etc/ssh/sshd_config
    echo -e "${GREEN}${ICON_OK} $desc 已禁用${RESET}"
    log "禁用 $desc ($option)"
    restart_ssh
  fi
}

install_ufw() {
  if ! command -v ufw &>/dev/null; then
    echo -e "${BLUE}安装 UFW 防火墙中...${RESET}"
    apt install ufw -y
    log "安装 UFW"
  fi
}

manage_ufw() {
  install_ufw
  echo -e "${BLUE}${ICON_LOCK} 当前 UFW 状态：$(ufw status | head -n1)${RESET}"
  echo "1) 启用防火墙"
  echo "2) 禁用防火墙"
  echo "3) 允许端口"
  echo "4) 拒绝端口"
  echo "5) 删除规则"
  echo "6) 查看所有规则"
  read -rp "请选择操作 [1-6]: " c
  case $c in
    1) ufw enable && echo -e "${GREEN}UFW 已启用${RESET}" && log "启用 UFW" ;;
    2) ufw disable && echo -e "${YELLOW}UFW 已禁用${RESET}" && log "禁用 UFW" ;;
    3) read -rp "输入端口号: " port && ufw allow "$port" && echo -e "${GREEN}已允许端口 $port${RESET}" && log "允许端口 $port" ;;
    4) read -rp "输入端口号: " port && ufw deny "$port" && echo -e "${GREEN}已拒绝端口 $port${RESET}" && log "拒绝端口 $port" ;;
    5) read -rp "输入端口号: " port && ufw delete allow "$port" && echo -e "${YELLOW}已删除允许端口 $port${RESET}" && log "删除端口规则 $port" ;;
    6) ufw status verbose ;;
    *) echo -e "${RED}无效输入${RESET}" ;;
  esac
}

install_fail2ban() {
  if ! command -v fail2ban-client &>/dev/null; then
    echo -e "${BLUE}安装 Fail2Ban...${RESET}"
    apt install fail2ban -y
    systemctl enable fail2ban --now
    log "安装并启用 Fail2Ban"
    echo -e "${GREEN}${ICON_OK} Fail2Ban 已安装并启用${RESET}"
  else
    echo -e "${GREEN}Fail2Ban 已安装${RESET}"
  fi
}

show_allowed_ports() {
  echo -e "${BLUE}${ICON_LOCK} 当前监听端口（SSH/UFW）:${RESET}"
  ss -tuln | awk 'NR>1 {print $5}' | awk -F: '{print $NF}' | sort -n | uniq | grep -E '^[0-9]+$'
  ufw status numbered | grep -E 'ALLOW|DENY' || echo "(无 UFW 规则)"
}

main_menu() {
  clear
  backup_sshd
  echo -e "${GREEN}=== 安全配置（SSH、防火墙、Fail2Ban）===${RESET}"
  echo "1) 修改 SSH 端口"
  echo "2) 设置是否允许 root 登录"
  echo "3) 设置是否允许密码登录"
  echo "4) 配置 UFW 防火墙"
  echo "5) 安装并启用 Fail2Ban"
  echo "6) 查看当前监听端口和防火墙规则"
  echo "0) 返回主菜单"
  read -rp "请输入选项 [0-6]: " choice
  case $choice in
    1) set_ssh_port ;;
    2) toggle_ssh_option "PermitRootLogin" "允许 Root 登录" ;;
    3) toggle_ssh_option "PasswordAuthentication" "密码登录" ;;
    4) manage_ufw ;;
    5) install_fail2ban ;;
    6) show_allowed_ports ;;
    0) return ;;
    *) echo -e "${RED}无效输入${RESET}" ;;
  esac
  read -rp "按回车返回..."
  main_menu
}

main_menu
