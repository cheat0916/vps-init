#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m' # 无色

clear_screen() {
  clear
}

pause() {
  read -rp "按回车键继续..."
}

print_line() {
  printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -
}

# --- 主界面 ---
show_system_info() {
  clear_screen
  print_line
  echo -e "${CYAN}        系统信息面板        ${NC}"
  print_line

  # 系统信息
  echo -e "${GREEN}主机名:${NC} $(hostname)"
  echo -e "${GREEN}系统版本:${NC} $(lsb_release -d 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
  echo -e "${GREEN}内核版本:${NC} $(uname -r)"
  echo -e "${GREEN}CPU信息:${NC} $(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^ *//')"
  mem_total=$(free -h | awk '/Mem:/ {print $2}')
  echo -e "${GREEN}内存总量:${NC} $mem_total"

  # 当前用户是否root
  if [ "$(id -u)" -eq 0 ]; then
    echo -e "${GREEN}当前用户:${NC} root (超级用户)"
  else
    echo -e "${YELLOW}当前用户:${NC} $(whoami)"
  fi

  # 网络连通性检测
  echo -e -n "${GREEN}网络状态检测:${NC} "
  if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
    echo -e "${GREEN}连通正常${NC}"
  else
    echo -e "${RED}无网络连接${NC}"
  fi

  print_line
  echo "1) 时区设置"
  echo "2) Swap管理"
  echo "3) 安全配置"
  echo "4) 用户管理"
  echo "0) 退出脚本"
  print_line
}

# --- 时区设置 ---
timezone_menu() {
  while true; do
    clear_screen
    print_line
    echo -e "${CYAN}        时区设置        ${NC}"
    print_line
    current_tz=$(timedatectl show --property=Timezone --value)
    current_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${GREEN}当前时区:${NC} $current_tz"
    echo -e "${GREEN}当前时间:${NC} $current_time"
    print_line
    echo "请选择新的时区:"
    echo "1) Asia/Shanghai (北京时间)"
    echo "2) Asia/Tokyo (东京时间)"
    echo "3) Europe/London (伦敦时间)"
    echo "4) Europe/Berlin (柏林时间)"
    echo "5) America/New_York (纽约时间)"
    echo "6) America/Los_Angeles (洛杉矶时间)"
    echo "0) 返回上级菜单"
    print_line
    read -rp "请输入数字选择: " tz_choice

    case $tz_choice in
      1) new_tz="Asia/Shanghai" ;;
      2) new_tz="Asia/Tokyo" ;;
      3) new_tz="Europe/London" ;;
      4) new_tz="Europe/Berlin" ;;
      5) new_tz="America/New_York" ;;
      6) new_tz="America/Los_Angeles" ;;
      0) return ;;
      *) echo -e "${RED}无效输入，请重新选择${NC}"; pause; continue ;;
    esac

    # 设置时区，需root权限
    if [ "$(id -u)" -ne 0 ]; then
      echo -e "${RED}需要root权限来更改时区${NC}"
      pause
      continue
    fi

    timedatectl set-timezone "$new_tz" && echo -e "${GREEN}时区设置成功为: $new_tz${NC}" || echo -e "${RED}设置失败${NC}"
    pause
  done
}

# --- swap管理 ---
swap_menu() {
  while true; do
    clear_screen
    print_line
    echo -e "${CYAN}        Swap管理        ${NC}"
    print_line

    # 当前swap信息
    swap_total=$(free -h | awk '/Swap:/ {print $2}')
    swap_used=$(free -h | awk '/Swap:/ {print $3}')
    swap_free=$(free -h | awk '/Swap:/ {print $4}')
    mem_total_bytes=$(free -b | awk '/Mem:/ {print $2}')
    mem_total_gb=$(echo "$mem_total_bytes" | awk '{printf "%.2f", $1/1024/1024/1024}')
    disk_total_bytes=$(df / --output=size -B1 | tail -1)
    disk_total_gb=$(echo "$disk_total_bytes" | awk '{printf "%.2f", $1/1024/1024/1024}')
    
    echo -e "${GREEN}Swap总量:${NC} $swap_total"
    echo -e "${GREEN}Swap已用:${NC} $swap_used"
    echo -e "${GREEN}Swap空闲:${NC} $swap_free"
    echo -e "${GREEN}物理内存:${NC} ${mem_total_gb} GB"
    echo -e "${GREEN}根分区磁盘总量:${NC} ${disk_total_gb} GB"

    # 建议swap大小 (简单建议：内存1~2倍，最大4GB)
    recommended_swap_gb=$(awk -v mem=$mem_total_gb 'BEGIN{if(mem<2)print 2; else if(mem<=4)print mem*1.5; else print 4}')
    echo -e "${YELLOW}建议的Swap大小约为: ${recommended_swap_gb} GB${NC}"

    print_line
    echo "1) 创建交换分区 (swapfile)"
    echo "2) 删除交换分区 (关闭swap)"
    echo "3) 查看当前swap详细信息"
    echo "0) 返回上级菜单"
    print_line
    read -rp "请选择操作: " swap_choice

    case $swap_choice in
      1)
        if [ "$(id -u)" -ne 0 ]; then
          echo -e "${RED}需要root权限操作${NC}"
          pause
          continue
        fi
        read -rp "请输入swap文件大小（单位GB，推荐${recommended_swap_gb}）: " size_gb
        if ! [[ "$size_gb" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
          echo -e "${RED}输入无效${NC}"
          pause
          continue
        fi
        swapfile_create "$size_gb"
        ;;
      2)
        if [ "$(id -u)" -ne 0 ]; then
          echo -e "${RED}需要root权限操作${NC}"
          pause
          continue
        fi
        swapfile_remove
        ;;
      3)
        swapon -s || echo "没有开启的swap"
        pause
        ;;
      0) return ;;
      *) echo -e "${RED}无效选择${NC}"; pause ;;
    esac
  done
}

swapfile_create() {
  size_gb=$1
  size_bytes=$(awk -v gb=$size_gb 'BEGIN{printf "%d", gb*1024*1024*1024}')
  echo "创建 ${size_gb}GB 的swap文件..."
  swapfile=/swapfile

  # 检查是否已有swapfile
  if swapon --show=NAME | grep -q "$swapfile"; then
    echo -e "${RED}Swap文件已经存在，请先删除再创建${NC}"
    pause
    return
  fi

  # 创建并设置权限
  fallocate -l "${size_bytes}" "$swapfile" || dd if=/dev/zero of="$swapfile" bs=1M count=$((size_gb*1024))
  chmod 600 "$swapfile"
  mkswap "$swapfile"
  swapon "$swapfile"
  echo "$swapfile none swap sw 0 0" >> /etc/fstab
  echo -e "${GREEN}Swap创建并启用成功${NC}"
  pause
}

swapfile_remove() {
  swapfile=/swapfile
  if swapon --show=NAME | grep -q "$swapfile"; then
    swapoff "$swapfile"
    sed -i "\|$swapfile|d" /etc/fstab
    rm -f "$swapfile"
    echo -e "${GREEN}Swap关闭并删除成功${NC}"
  else
    echo "未检测到swap文件"
  fi
  pause
}

# --- 安全配置 ---
security_menu() {
  while true; do
    clear_screen
    print_line
    echo -e "${CYAN}        安全配置        ${NC}"
    print_line

    # 防火墙状态
    ufw_status=$(ufw status 2>/dev/null | head -1)
    ssh_port=$(ss -tnlp | grep sshd | awk '{print $4}' | sed 's/.*://g' | head -1)
    if [ -z "$ssh_port" ]; then ssh_port="22 (默认)"; fi

    echo -e "${GREEN}防火墙(UFW)状态:${NC} $ufw_status"
    echo -e "${GREEN}SSH端口:${NC} $ssh_port"
    print_line
    echo "1) 修改SSH端口"
    echo "2) 安装UFW防火墙"
    echo "3) 启用/禁用端口"
    echo "4) 查看允许/拒绝端口规则"
    echo "0) 返回上级菜单"
    print_line
    read -rp "请选择操作: " sec_choice

    case $sec_choice in
      1) modify_ssh_port ;;
      2) install_ufw ;;
      3) ufw_manage_ports ;;
      4) ufw_show_rules ;;
      0) return ;;
      *) echo -e "${RED}无效选择${NC}"; pause ;;
    esac
  done
}

modify_ssh_port() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}需要root权限${NC}"
    pause
    return
  fi

  read -rp "请输入新的SSH端口(1024-65535): " new_port
  if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1024 ] || [ "$new_port" -gt 65535 ]; then
    echo -e "${RED}端口号无效${NC}"
    pause
    return
  fi

  ssh_config="/etc/ssh/sshd_config"
  if grep -q "^#Port" "$ssh_config"; then
    sed -i "s/^#Port.*/Port $new_port/" "$ssh_config"
  elif grep -q "^Port" "$ssh_config"; then
    sed -i "s/^Port.*/Port $new_port/" "$ssh_config"
  else
    echo "Port $new_port" >> "$ssh_config"
  fi

  systemctl restart sshd && echo -e "${GREEN}SSH端口修改成功，新端口: $new_port${NC}" || echo -e "${RED}重启SSH失败，可能未生效${NC}"
  pause
}

install_ufw() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}需要root权限${NC}"
    pause
    return
  fi

  if command -v ufw >/dev/null 2>&1; then
    echo -e "${GREEN}UFW已经安装${NC}"
  else
    echo "正在安装UFW..."
    apt update && apt install -y ufw && echo -e "${GREEN}安装成功${NC}" || echo -e "${RED}安装失败${NC}"
  fi
  pause
}

ufw_manage_ports() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}需要root权限${NC}"
    pause
    return
  fi

  while true; do
    clear_screen
    echo "UFW端口管理"
    echo "1) 允许端口"
    echo "2) 禁用端口"
    echo "0) 返回"
    read -rp "选择操作: " port_choice

    case $port_choice in
      1)
        read -rp "请输入要允许的端口号: " port
        if ! [[ "$port" =~ ^[0-9]+$ ]]; then
          echo "无效端口"
          pause
          continue
        fi
        ufw allow "$port" && echo "端口 $port 已允许" || echo "操作失败"
        pause
        ;;
      2)
        read -rp "请输入要禁用的端口号: " port
        if ! [[ "$port" =~ ^[0-9]+$ ]]; then
          echo "无效端口"
          pause
          continue
        fi
        ufw deny "$port" && echo "端口 $port 已禁用" || echo "操作失败"
        pause
        ;;
      0) return ;;
      *) echo "无效选择"; pause ;;
    esac
  done
}

ufw_show_rules() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}需要root权限${NC}"
    pause
    return
  fi

  ufw status verbose
  pause
}

# --- 用户管理 ---
user_manage_menu() {
  while true; do
    clear_screen
    print_line
    echo -e "${CYAN}        用户管理        ${NC}"
    print_line

    echo -e "${GREEN}当前系统用户列表:${NC}"
    # 列出非系统用户
    awk -F: '$3>=1000 && $3<65534 {print $1}' /etc/passwd | column

    print_line
    echo "1) 添加新用户"
    echo "2) 删除用户"
    echo "3) 修改用户密码"
    echo "0) 返回上级菜单"
    print_line

    read -rp "请选择操作: " user_choice

    case $user_choice in
      1) add_user ;;
      2) del_user ;;
      3) passwd_user ;;
      0) return ;;
      *) echo -e "${RED}无效选择${NC}"; pause ;;
    esac
  done
}

add_user() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}需要root权限${NC}"
    pause
    return
  fi

  read -rp "请输入新用户名: " new_user
  if id "$new_user" &>/dev/null; then
    echo "用户已存在"
    pause
    return
  fi

  read -rp "是否赋予sudo权限? (y/n): " sudo_choice
  sudo_choice=${sudo_choice,,}

  useradd -m "$new_user" && echo "用户创建成功" || { echo "创建失败"; pause; return; }
  passwd "$new_user"

  if [[ "$sudo_choice" == "y" ]]; then
    usermod -aG sudo "$new_user"
    echo "已赋予sudo权限"
  fi

  pause
}

del_user() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}需要root权限${NC}"
    pause
    return
  fi

  read -rp "请输入要删除的用户名: " del_user
  if ! id "$del_user" &>/dev/null; then
    echo "用户不存在"
    pause
    return
  fi

  read -rp "确定删除用户 $del_user ? (此操作不可恢复) (y/n): " confirm
  confirm=${confirm,,}
  if [[ "$confirm" == "y" ]]; then
    userdel -r "$del_user" && echo "用户已删除" || echo "删除失败"
  else
    echo "取消操作"
  fi
  pause
}

passwd_user() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}需要root权限${NC}"
    pause
    return
  fi

  read -rp "请输入要修改密码的用户名: " usr
  if ! id "$usr" &>/dev/null; then
    echo "用户不存在"
    pause
    return
  fi

  passwd "$usr"
  pause
}

# --- 主循环 ---
while true; do
  show_system_info
  read -rp "请输入数字选择功能: " main_choice
  case $main_choice in
    1) timezone_menu ;;
    2) swap_menu ;;
    3) security_menu ;;
    4) user_manage_menu ;;
    0) echo "退出脚本"; exit 0 ;;
    *) echo -e "${RED}无效输入，请重新选择${NC}"; pause ;;
  esac
done
