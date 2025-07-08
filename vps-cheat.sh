# ========= 主菜单 =========
main_menu() {
  clear
  print_logo
  msg welcome
  msg warning
  echo

  echo -e "${PURPLE}=== $( [[ $LANGUAGE == 'EN' ]] && echo 'System Information' || echo '系统信息' ) ===${RESET}"

  if [[ $LANGUAGE == "EN" ]]; then
    echo -e "Kernel: $(uname -r)"
    echo -e "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
    echo -e "Architecture: $(uname -m)"
    echo -e "User: $(whoami)"
  else
    echo -e "内核版本: $(uname -r)"
    echo -e "操作系统: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
    echo -e "系统架构: $(uname -m)"
    echo -e "当前用户: $(whoami)"
  fi

  check_network
  echo

  if [[ $LANGUAGE == "EN" ]]; then
    echo "1) Fix Hostname and Sources"
    echo "2) Clean System Garbage"
    echo "3) Install WARP"
    echo "4) Install Docker"
    echo "5) Performance Test"
    echo "6) Swap Manager"
    echo "7) Security Settings"
    echo "8) Timezone Settings"
    echo "9) User Manager"
    echo "0) Exit"
    read -p "Choose function [0-9]: " opt
  else
    echo "1) 修复主机名和软件源"
    echo "2) 清理系统垃圾"
    echo "3) 安装 WARP"
    echo "4) 安装 Docker"
    echo "5) 性能测试"
    echo "6) Swap 管理"
    echo "7) 安全配置"
    echo "8) 时间与时区设置"
    echo "9) 用户管理"
    echo "0) 退出脚本"
    read -p "请选择功能 [0-9]: " opt
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
      if [[ $LANGUAGE == "EN" ]]; then
        echo -e "${YELLOW}Security Settings module coming soon.${RESET}"
      else
        echo -e "${YELLOW}安全配置模块敬请期待。${RESET}"
      fi
      sleep 2
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

# ========= 时间设置 =========
time_timezone() {
  while true; do
    clear
    # 当前时区和时间显示
    current_tz=$(cat /etc/timezone 2>/dev/null || timedatectl | grep "Time zone" | awk '{print $3}')
    current_time=$(date +"%Y-%m-%d %H:%M:%S")
    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== Timezone Settings ===${RESET}"
      echo "Current timezone: $current_tz"
      echo "Current time: $current_time"
      echo
      echo "Select a timezone:"
      echo "1) Asia/Shanghai"
      echo "2) Asia/Tokyo"
      echo "3) Europe/London"
      echo "4) America/New_York"
      echo "5) Etc/UTC"
      echo "6) Enter manually"
      echo "0) Return"
      read -p "Choose [0-6]: " tz_choice
    else
      echo -e "${GREEN}=== 时间与时区设置 ===${RESET}"
      echo "当前时区: $current_tz"
      echo "当前时间: $current_time"
      echo
      echo "请选择时区:"
      echo "1) 亚洲/上海 (Asia/Shanghai)"
      echo "2) 亚洲/东京 (Asia/Tokyo)"
      echo "3) 欧洲/伦敦 (Europe/London)"
      echo "4) 美洲/纽约 (America/New_York)"
      echo "5) 世界协调时 (Etc/UTC)"
      echo "6) 手动输入时区"
      echo "0) 返回"
      read -p "请选择 [0-6]: " tz_choice
    fi

    case $tz_choice in
      0)
        break
        ;;
      1) tz="Asia/Shanghai" ;;
      2) tz="Asia/Tokyo" ;;
      3) tz="Europe/London" ;;
      4) tz="America/New_York" ;;
      5) tz="Etc/UTC" ;;
      6)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter timezone (e.g. Asia/Shanghai): " tz
        else
          read -p "请输入时区（例如 Asia/Shanghai）: " tz
        fi
        ;;
      *)
        msg invalid
        sleep 1
        continue
        ;;
    esac

    if [ -f /usr/share/zoneinfo/"$tz" ]; then
      ln -sf /usr/share/zoneinfo/"$tz" /etc/localtime
      echo "$tz" >/etc/timezone
      hwclock --systohc
      if [[ $LANGUAGE == "EN" ]]; then
        echo -e "${GREEN}Timezone set to $tz.${RESET}"
      else
        echo -e "${GREEN}时区已设置为 $tz。${RESET}"
      fi
      sleep 2
      break
    else
      if [[ $LANGUAGE == "EN" ]]; then
        echo -e "${RED}Invalid timezone!${RESET}"
      else
        echo -e "${RED}无效的时区！${RESET}"
      fi
      sleep 2
    fi
  done
}

# ========= Swap 管理 =========
swap_manager() {
  while true; do
    clear

    # 当前swap状态
    swap_total=$(free -m | awk '/Swap:/ {print $2}')
    swap_used=$(free -m | awk '/Swap:/ {print $3}')
    swap_free=$(free -m | awk '/Swap:/ {print $4}')
    mem_total=$(free -m | awk '/Mem:/ {print $2}')
    disk_root=$(df -h / | awk 'NR==2 {print $2}')
    disk_avail=$(df -h / | awk 'NR==2 {print $4}')

    if [[ $LANGUAGE == "EN" ]]; then
      echo -e "${GREEN}=== Swap Manager ===${RESET}"
      echo "Total RAM: ${mem_total} MB"
      echo "Root Disk Size: ${disk_root}"
      echo "Available Disk Space: ${disk_avail}"
      if [[ $swap_total -gt 0 ]]; then
        echo "Current Swap: ${swap_total} MB (Used: ${swap_used} MB, Free: ${swap_free} MB)"
      else
        echo "Swap is currently disabled."
      fi
      # 简单建议：通常建议swap为内存大小的1-2倍，最大不要超过磁盘可用空间
      recommend_swap=$(( mem_total * 2 ))
      echo "Recommended swap size: ${recommend_swap} MB (usually 1-2x RAM)"
      echo
      echo "1) Create/Resize Swap"
      echo "2) Delete Swap"
      echo "0) Return"
      read -p "Choose option [0-2]: " swap_choice
    else
      echo -e "${GREEN}=== Swap 管理 ===${RESET}"
      echo "内存总量: ${mem_total} MB"
      echo "根分区磁盘大小: ${disk_root}"
      echo "可用磁盘空间: ${disk_avail}"
      if [[ $swap_total -gt 0 ]]; then
        echo "当前 Swap: ${swap_total} MB (已用: ${swap_used} MB, 空闲: ${swap_free} MB)"
      else
        echo "当前未启用 Swap。"
      fi
      echo "建议 Swap 大小: ${recommend_swap} MB （一般为内存大小的1-2倍）"
      echo
      echo "1) 创建/调整 Swap"
      echo "2) 删除 Swap"
      echo "0) 返回"
      read -p "请选择 [0-2]: " swap_choice
    fi

    case $swap_choice in
      0)
        break
        ;;
      1)
        if [[ $LANGUAGE == "EN" ]]; then
          read -p "Enter swap size in MB (e.g. 2048): " size_mb
        else
          read -p "请输入 Swap 大小（单位 MB，例如 2048）: " size_mb
        fi

        if ! [[ "$size_mb" =~ ^[0-9]+$ ]]; then
          [[ $LANGUAGE == "EN" ]] && echo -e "${RED}Invalid size!${RESET}" || echo -e "${RED}无效大小！${RESET}"
          sleep 1
          continue
        fi

        swapoff -a
        rm -f /swapfile
        fallocate -l "${size_mb}M" /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile

        if ! grep -q '/swapfile' /etc/fstab; then
          echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi

        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Swap file created with size ${size_mb} MB.${RESET}" || echo -e "${GREEN}Swap 文件创建成功，大小 ${size_mb} MB。${RESET}"
        sleep 2
        ;;
      2)
        swapoff -a
        rm -f /swapfile
        sed -i '/\/swapfile/d' /etc/fstab
        [[ $LANGUAGE == "EN" ]] && echo -e "${GREEN}Swap file deleted.${RESET}" || echo -e "${GREEN}Swap 文件已删除。${RESET}"
        sleep 2
        ;;
      *)
        msg invalid
        sleep 1
        ;;
    esac
  done
}
