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
          read -p "请输入Swap大小 (GB): " size_gb
        fi

        if [[ ! $size_gb =~ ^[0-9]+$ ]]; then
          msg invalid
          continue
        fi

        swapoff -a
        rm -f /swapfile
        fallocate -l "${size_gb}G" /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile

        if ! grep -q "/swapfile" /etc/fstab; then
          echo "/swapfile none swap sw 0 0" >> /etc/fstab
        fi

        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Swap file set to ${size_gb}GB and activated.${RESET}" || echo -e "${GREEN}Swap 文件已创建并激活，大小为 ${size_gb}GB。${RESET}"
        sleep 2
        ;;
      2)
        swapoff -a
        rm -f /swapfile
        sed -i '/swapfile/d' /etc/fstab
        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Swap file deleted.${RESET}" || echo -e "${GREEN}Swap 文件已删除。${RESET}"
        sleep 2
        ;;
      3)
        break
        ;;
      *)
        msg invalid
        ;;
    esac
  done
}

# ========= 时间与时区设置 =========
time_timezone() {
  while true; do
    clear
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== Time & Timezone Settings ===${RESET}"
      echo "1. Show current time & timezone"
      echo "2. Set timezone"
      echo "3. Sync time with NTP"
      echo "4. Return to main menu"
      read -p "Choose [1-4]: " tt_opt
    else
      echo -e "${GREEN}=== 时间与时区设置 ===${RESET}"
      echo "1. 显示当前时间与时区"
      echo "2. 设置时区"
      echo "3. 同步时间 (NTP)"
      echo "4. 返回主菜单"
      read -p "请选择 [1-4]: " tt_opt
    fi

    case $tt_opt in
      1)
        date
        timedatectl
        msg return_menu
        ;;
      2)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter timezone (e.g. Asia/Shanghai): " tz
        else
          read -p "请输入时区 (例如 Asia/Shanghai): " tz
        fi
        timedatectl set-timezone "$tz" && date && echo -e "${GREEN}Timezone set to $tz${RESET}" || echo -e "${RED}Failed to set timezone.${RESET}"
        msg return_menu
        ;;
      3)
        systemctl restart systemd-timesyncd || systemctl restart ntp || true
        if command -v ntpdate &>/dev/null; then
          ntpdate pool.ntp.org
        fi
        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Time synchronized.${RESET}" || echo -e "${GREEN}时间同步完成。${RESET}"
        msg return_menu
        ;;
      4)
        break
        ;;
      *)
        msg invalid
        ;;
    esac
  done
}

# ========= 用户管理 =========
user_manager() {
  while true; do
    clear
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== User Management ===${RESET}"
      echo "1. Add user"
      echo "2. Delete user"
      echo "3. List users"
      echo "4. Return to main menu"
      read -p "Choose [1-4]: " u_opt
    else
      echo -e "${GREEN}=== 用户管理 ===${RESET}"
      echo "1. 添加用户"
      echo "2. 删除用户"
      echo "3. 查看用户列表"
      echo "4. 返回主菜单"
      read -p "请选择 [1-4]: " u_opt
    fi

    case $u_opt in
      1)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter username to add: " uname
        else
          read -p "请输入要添加的用户名: " uname
        fi
        adduser "$uname"
        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}User added: $uname${RESET}" || echo -e "${GREEN}用户已添加: $uname${RESET}"
        msg return_menu
        ;;
      2)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter username to delete: " uname
        else
          read -p "请输入要删除的用户名: " uname
        fi
        deluser "$uname"
        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}User deleted: $uname${RESET}" || echo -e "${GREEN}用户已删除: $uname${RESET}"
        msg return_menu
        ;;
      3)
        cut -d: -f1 /etc/passwd
        msg return_menu
        ;;
      4)
        break
        ;;
      *)
        msg invalid
        ;;
    esac
  done
}

# ========= 安全配置 =========
security_settings() {
  while true; do
    clear
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== Security Settings ===${RESET}"
      echo "1) Disable root SSH login"
      echo "2) Install and enable fail2ban"
      echo "3) Setup basic firewall (ufw)"
      echo "4) Return to main menu"
      read -p "Choose [1-4]: " sec_opt
    else
      echo -e "${GREEN}=== 安全配置 ===${RESET}"
      echo "1) 禁止 root 用户 SSH 登录"
      echo "2) 安装并启用 fail2ban"
      echo "3) 设置基础防火墙 (ufw)"
      echo "4) 返回主菜单"
      read -p "请选择 [1-4]: " sec_opt
    fi

    case $sec_opt in
      1)
        sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
        systemctl restart sshd
        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Root SSH login disabled.${RESET}" || echo -e "${GREEN}已禁止 root 用户 SSH 登录。${RESET}"
        sleep 2
        ;;
      2)
        if command -v apt >/dev/null 2>&1; then
          apt update && apt install -y fail2ban
          systemctl enable --now fail2ban
          [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}fail2ban installed and enabled.${RESET}" || echo -e "${GREEN}fail2ban 已安装并启用。${RESET}"
        elif command -v yum >/dev/null 2>&1; then
          yum install -y epel-release
          yum install -y fail2ban
          systemctl enable --now fail2ban
          [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}fail2ban installed and enabled.${RESET}" || echo -e "${GREEN}fail2ban 已安装并启用。${RESET}"
        else
          [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Unsupported system for fail2ban installation.${RESET}" || echo -e "${RED}不支持的系统，无法安装 fail2ban。${RESET}"
        fi
        sleep 2
        ;;
      3)
        if command -v apt >/dev/null 2>&1; then
          apt update && apt install -y ufw
          ufw default deny incoming
          ufw default allow outgoing
          ufw allow ssh
          ufw --force enable
          [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}ufw installed and basic rules applied.${RESET}" || echo -e "${GREEN}ufw 已安装并配置基本规则。${RESET}"
        else
          [[ $LANGUAGE == "EN" ]] && echo -e "${RED}ufw is not supported or not available.${RESET}" || echo -e "${RED}不支持 ufw 或未安装。${RESET}"
        fi
        sleep 2
        ;;
      4)
        break
        ;;
      *)
        msg invalid
        ;;
    esac
  done
}

# ========= 主菜单 =========
while true; do
  clear
  print_logo
  check_network
  echo
  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "${PURPLE}1) Fix hostname and update sources"
    echo "2) Clean cache"
    echo "3) Install WARP"
    echo "4) Install Docker"
    echo "5) Run benchmark"
    echo "6) Swap management"
    echo "7) Security settings"
    echo "8) Time & timezone"
    echo "9) User manager"
    echo "0) Exit"
    read -p "Choose an option [0-9]: " opt
  else
    echo -e "${PURPLE}1) 修复主机名和更新软件源"
    echo "2) 清理缓存"
    echo "3) 安装 WARP"
    echo "4) 安装 Docker"
    echo "5) 性能测试"
    echo "6) Swap 管理"
    echo "7) 安全配置"
    echo "8) 时间与时区"
    echo "9) 用户管理"
    echo "0) 退出"
    read -p "请选择一个选项 [0-9]: " opt
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
      security_settings
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
done
