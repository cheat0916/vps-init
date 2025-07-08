#!/bin/bash

# ========= 色彩定义 =========
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
RESET="\033[0m"

# ========= 兼容性检测 =========
SUPPORT_UTF8=$(locale charmap 2>/dev/null | grep -iq "UTF-8" && echo 1 || echo 0)

# ========= LOGO =========
if [ "$SUPPORT_UTF8" -eq 1 ]; then
  CHEAT_LOGO="${GREEN}=== 🧠 CHEAT VPS TOOLKIT ===${RESET}"
else
  CHEAT_LOGO="${GREEN}=== CHEAT VPS TOOLKIT ===${RESET}"
fi

# ========= 多语言初始化 =========
LANGUAGE="CN"
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

# ========= 基础功能 =========
fix_hostname() {
  echo -e "${BLUE}检测主机名...${RESET}"
  local hn=$(hostname)
  if grep -q "$hn" /etc/hosts; then
    echo -e "${GREEN}主机名已存在 /etc/hosts${RESET}"
  else
    echo "127.0.0.1 $hn" >> /etc/hosts
    echo -e "${GREEN}添加主机名到 /etc/hosts${RESET}"
  fi
}

fix_sources() {
  echo -e "${BLUE}修复软件源...${RESET}"
  if [ -f /etc/debian_version ]; then
    apt update && apt upgrade -y
  elif grep -qi centos /etc/os-release; then
    yum makecache && yum update -y
  else
    echo -e "${RED}暂不支持的系统类型${RESET}"
  fi
}

clean_garbage() {
  echo -e "${BLUE}清理缓存...${RESET}"
  if command -v apt >/dev/null 2>&1; then
    apt autoremove -y && apt clean && echo -e "${GREEN}完成${RESET}"
  elif command -v yum >/dev/null 2>&1; then
    yum autoremove -y && yum clean all && echo -e "${GREEN}完成${RESET}"
  else
    echo -e "${RED}未知包管理器，无法清理缓存${RESET}"
  fi
}

install_warp() {
  echo -e "${BLUE}安装 WARP...${RESET}"
  bash <(wget -qO- https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh)
}

install_docker() {
  echo -e "${BLUE}安装 Docker...${RESET}"
  curl -fsSL https://get.docker.com | bash
  systemctl enable docker --now
  echo -e "${GREEN}Docker 已安装${RESET}"
}

run_benchmark() {
  echo -e "${BLUE}运行性能测试...${RESET}"
  curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
}

exit_script() {
  echo -e "${GREEN}感谢使用，再见！${RESET}"
  exit 0
}

# ========= Swap 管理模块 =========
swap_manager() {
  while true; do
    clear
    echo -e "${GREEN}=== Swap 管理 ===${RESET}"
    echo "当前 Swap 状态："
    swapon --show || echo "无 Swap"
    echo
    echo "1. 创建 Swap 文件 (1GB)"
    echo "2. 删除 Swap 文件"
    echo "3. 返回主菜单"
    read -p "请选择 [1-3]: " sm_opt
    case $sm_opt in
      1)
        if swapon --show | grep -q swapfile; then
          echo -e "${YELLOW}Swap 文件已存在，先删除后再创建。${RESET}"
          swapoff /swapfile
          rm -f /swapfile
        fi
        fallocate -l 1G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
        echo -e "${GREEN}Swap 文件创建并启用完成。${RESET}"
        ;;
      2)
        if swapon --show | grep -q swapfile; then
          swapoff /swapfile
          sed -i '/swapfile/d' /etc/fstab
          rm -f /swapfile
          echo -e "${GREEN}Swap 文件已删除。${RESET}"
        else
          echo -e "${YELLOW}没有检测到 Swap 文件。${RESET}"
        fi
        ;;
      3)
        break
        ;;
      *)
        msg invalid
        ;;
    esac
    msg return_menu
  done
}

# ========= 安全配置模块 =========
security_config() {
  while true; do
    clear
    echo -e "${GREEN}=== 安全配置（SSH、防火墙、Fail2Ban） ===${RESET}"
    echo "1. 修改 SSH 端口"
    echo "2. 启用 UFW 防火墙"
    echo "3. 安装并配置 Fail2Ban"
    echo "4. 返回主菜单"
    read -p "请选择 [1-4]: " sc_opt
    case $sc_opt in
      1)
        read -p "请输入新的 SSH 端口（默认 22）: " new_port
        new_port=${new_port:-22}
        sed -i "s/#Port 22/Port $new_port/" /etc/ssh/sshd_config
        systemctl restart sshd
        echo -e "${GREEN}SSH 端口已修改为 $new_port 并重启 sshd。${RESET}"
        ;;
      2)
        if command -v ufw >/dev/null 2>&1; then
          ufw enable
          ufw allow ssh
          echo -e "${GREEN}UFW 防火墙已启用并允许 SSH。${RESET}"
        else
          echo -e "${YELLOW}未检测到 UFW，尝试安装中...${RESET}"
          if [ -f /etc/debian_version ]; then
            apt update && apt install ufw -y
            ufw enable
            ufw allow ssh
            echo -e "${GREEN}UFW 防火墙已安装并启用。${RESET}"
          else
            echo -e "${RED}当前系统不支持自动安装 UFW。${RESET}"
          fi
        fi
        ;;
      3)
        if command -v fail2ban-server >/dev/null 2>&1; then
          systemctl enable --now fail2ban
          echo -e "${GREEN}Fail2Ban 已启用。${RESET}"
        else
          echo -e "${YELLOW}Fail2Ban 未安装，正在安装...${RESET}"
          if [ -f /etc/debian_version ]; then
            apt update && apt install fail2ban -y
            systemctl enable --now fail2ban
            echo -e "${GREEN}Fail2Ban 已安装并启用。${RESET}"
          else
            echo -e "${RED}当前系统不支持自动安装 Fail2Ban。${RESET}"
          fi
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

# ========= 系统时间与时区配置模块 =========
time_timezone() {
  while true; do
    clear
    echo -e "${GREEN}=== 系统时间与时区配置 ===${RESET}"
    echo "当前时间：$(date)"
    echo "当前时区：$(timedatectl show --property=Timezone --value)"
    echo
    echo "1. 设置时区"
    echo "2. 同步网络时间 (NTP)"
    echo "3. 返回主菜单"
    read -p "请选择 [1-3]: " tt_opt
    case $tt_opt in
      1)
        timedatectl list-timezones
        read -p "请输入时区名称（如 Asia/Shanghai）: " tz
        if timedatectl set-timezone "$tz"; then
          echo -e "${GREEN}时区已设置为 $tz${RESET}"
        else
          echo -e "${RED}设置时区失败，请检查输入是否正确。${RESET}"
        fi
        ;;
      2)
        if command -v timedatectl >/dev/null 2>&1; then
          timedatectl set-ntp true
          echo -e "${GREEN}NTP 同步已开启。${RESET}"
        else
          echo -e "${RED}timedatectl 命令不存在，无法同步时间。${RESET}"
        fi
        ;;
      3)
        break
        ;;
      *)
        msg invalid
        ;;
    esac
    msg return_menu
  done
}

# ========= 用户管理模块 =========
user_manager() {
  while true; do
    clear
    echo -e "${GREEN}=== 用户管理 ===${RESET}"
    echo "当前用户列表："
    cut -d: -f1 /etc/passwd
    echo
    echo "1. 添加用户"
    echo "2. 删除用户"
    echo "3. 修改用户密码"
    echo "4. 返回主菜单"
    read -p "请选择 [1-4]: " um_opt
    case $um_opt in
      1)
        read -p "请输入新用户名: " new_user
        if id "$new_user" &>/dev/null; then
          echo -e "${YELLOW}用户已存在。${RESET}"
        else
          adduser "$new_user"
          echo -e "${GREEN}用户 $new_user 添加成功。${RESET}"
        fi
        ;;
      2)
        read -p "请输入要删除的用户名: " del_user
        if id "$del_user" &>/dev/null; then
          deluser "$del_user"
          echo -e "${GREEN}用户 $del_user 删除成功。${RESET}"
        else
          echo -e "${YELLOW}用户不存在。${RESET}"
        fi
        ;;
      3)
        read -p "请输入用户名: " pass_user
        if id "$pass_user" &>/dev/null; then
          passwd "$pass_user"
          echo -e "${GREEN}用户 $pass_user 密码已修改。${RESET}"
        else
          echo -e "${YELLOW}用户不存在。${RESET}"
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
  echo -e "$CHEAT_LOGO"
  msg welcome
  msg warning
  echo
  echo "当前系统信息："
  uname -a
  echo
  echo "1. 修复主机名和软件源"
  echo "2. 清理系统垃圾"
  echo "3. 安装 WARP"
  echo "4. 安装 Docker"
  echo "5. 性能测试"
  echo "6. Swap 管理"
  echo "7. 安全配置"
  echo "8. 时间与时区设置"
  echo "9. 用户管理"
  echo "0. 退出脚本"
  echo
  read -p "请选择功能 [0-9]: " opt
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
      security_config
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

# ========= 程序入口 =========
msg choose_lang

while true; do
  main_menu
done
