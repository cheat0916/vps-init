#!/bin/bash
# modules/security_config.sh - 安全配置模块（SSH，UFW，Fail2Ban）

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)
ICON_INFO=$([ $SUPPORT_UTF8 -eq 1 ] && echo "🔐" || echo "[SEC]")
ICON_WARN=$([ $SUPPORT_UTF8 -eq 1 ] && echo "⚠️" || echo "[WARN]")
ICON_OK=$([ $SUPPORT_UTF8 -eq 1 ] && echo "✅" || echo "[OK]")

LOGFILE="/var/log/vps_security_config.log"
touch $LOGFILE 2>/dev/null || LOGFILE="/tmp/vps_security_config.log"

backup_ssh_config="/etc/ssh/sshd_config.bak.$(date +%F-%T)"

log() {
  echo "$(date '+%F %T') $1" >> "$LOGFILE"
}

backup_ssh() {
  if [ ! -f "$backup_ssh_config" ]; then
    cp /etc/ssh/sshd_config "$backup_ssh_config"
    log "备份SSH配置文件到 $backup_ssh_config"
  fi
}

show_ssh_config() {
  echo -e "${BLUE}${ICON_INFO} 当前SSH配置节选：${RESET}"
  grep -E "^(Port|PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config || echo "无相关配置"
  echo
  echo -e "${BLUE}${ICON_INFO} 当前开放端口（TCP）："
  ss -tlnp | grep LISTEN | awk '{print $5}' | cut -d':' -f2 | sort -u | xargs
}

change_ssh_port() {
  read -rp "请输入新的SSH端口号（1024-65535，默认22）: " newport
  [[ -z "$newport" ]] && newport=22
  if ! [[ "$newport" =~ ^[0-9]+$ ]] || [ "$newport" -lt 1024 ] || [ "$newport" -gt 65535 ]; then
    echo -e "${RED}${ICON_WARN} 无效端口号${RESET}"
    return 1
  fi
  backup_ssh
  sed -i "s/^#Port .*/Port $newport/" /etc/ssh/sshd_config
  sed -i "/^Port /c\Port $newport" /etc/ssh/sshd_config
  systemctl restart sshd && echo -e "${GREEN}${ICON_OK} SSH端口已更改为 $newport${RESET}" && log "修改SSH端口为 $newport"
}

set_root_login() {
  echo "允许root远程登录吗？"
  select yn in "是" "否" "取消"; do
    case $yn in
      是)
        backup_ssh
        sed -i "s/^PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
        systemctl restart sshd
        echo -e "${GREEN}${ICON_OK} 允许root远程登录${RESET}"
        log "允许root远程登录"
        break;;
      否)
        backup_ssh
        sed -i "s/^PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
        systemctl restart sshd
        echo -e "${GREEN}${ICON_OK} 禁止root远程登录${RESET}"
        log "禁止root远程登录"
        break;;
      取消) break ;;
    esac
  done
}

set_password_auth() {
  echo "允许密码登录吗？"
  select yn in "是" "否" "取消"; do
    case $yn in
      是)
        backup_ssh
        sed -i "s/^PasswordAuthentication .*/PasswordAuthentication yes/" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
        systemctl restart sshd
        echo -e "${GREEN}${ICON_OK} 允许密码登录${RESET}"
        log "允许密码登录"
        break;;
      否)
        backup_ssh
        sed -i "s/^PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config || echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
        systemctl restart sshd
        echo -e "${GREEN}${ICON_OK} 禁止密码登录${RESET}"
        log "禁止密码登录"
        break;;
      取消) break ;;
    esac
  done
}

install_ufw() {
  echo -e "${BLUE}${ICON_INFO} 检查UFW是否安装...${RESET}"
  if command -v ufw >/dev/null 2>&1; then
    echo -e "${GREEN}${ICON_OK} UFW已安装${RESET}"
  else
    echo -e "${YELLOW}${ICON_WARN} UFW未安装，是否安装？(y/n)"
    read -r ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      if [ -f /etc/debian_version ]; then
        apt update && apt install ufw -y
      elif grep -qi centos /etc/os-release; then
        yum install epel-release -y
        yum install ufw -y
      else
        echo -e "${RED}${ICON_WARN} 不支持的系统，无法安装UFW${RESET}"
        return
      fi
      echo -e "${GREEN}${ICON_OK} UFW安装完成${RESET}"
      log "安装UFW"
    else
      echo -e "${YELLOW}${ICON_WARN} 放弃安装UFW${RESET}"
      return
    fi
  fi
}

config_ufw() {
  echo -e "${BLUE}${ICON_INFO} 当前UFW状态："
  ufw status verbose
  echo
  echo "请配置允许的端口（默认允许SSH端口）："
  read -rp "输入允许端口（多个用空格分开，默认22）: " ports
  if [ -z "$ports" ]; then ports="22"; fi

  for p in $ports; do
    ufw allow "$p"/tcp
    echo -e "${GREEN}${ICON_OK} 允许端口 $p${RESET}"
  done

  ufw --force enable
  echo -e "${GREEN}${ICON_OK} UFW已启用并配置完成${RESET}"
  log "配置UFW允许端口: $ports"
}

main_menu() {
  clear
  echo -e "${GREEN}=== 安全配置模块 ===${RESET}"
  echo
  show_ssh_config
  echo
  echo "请选择操作："
  echo "1) 修改SSH端口"
  echo "2) 配置root远程登录"
  echo "3) 配置密码登录"
  echo "4) 安装并配置UFW防火墙"
  echo "5) 查看当前防火墙状态"
  echo "0) 返回主菜单"
  read -rp "请输入选项: " choice
  case $choice in
    1) change_ssh_port ;;
    2) set_root_login ;;
    3) set_password_auth ;;
    4) install_ufw; config_ufw ;;
    5) ufw status verbose ;;
    0) exit 0 ;;
    *) echo -e "${RED}${ICON_WARN} 无效选择${RESET}" ;;
  esac
  read -rp "按回车返回菜单..."
  main_menu
}

# 支持命令行参数 (后续可以扩展)

main_menu
