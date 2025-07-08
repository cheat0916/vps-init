<p align="center">
  <img src="https://raw.githubusercontent.com/cheat0916/vps-init/master/banner.png" alt="Cheat VPS Init Banner" width="100%">
</p>

<h1 align="center">Cheat VPS Init Toolkit</h1>
<p align="center">🚀 VPS 一键初始化脚本｜自动配置系统环境｜中文 / English 多语言支持</p>

<p align="center">
  <img src="https://img.shields.io/github/repo-size/cheat0916/vps-init" />
  <img src="https://img.shields.io/github/last-commit/cheat0916/vps-init" />
  <img src="https://img.shields.io/github/license/cheat0916/vps-init" />
  <img src="https://img.shields.io/github/stars/cheat0916/vps-init?style=social" />
</p>

---

## 📦 项目简介 / About

**Cheat VPS Init** 是一个轻量级的 VPS 初始化工具，支持主流 Linux 发行版，提供中文/英文界面切换、模块化系统配置、可交互菜单，帮助你高效完成 VPS 初始环境设置。

✨ 支持以 `bash <(wget -qO- xxx)` 一键运行，适配各类小内存 VPS。

---

## 🚀 快速开始 / Quick Start

**推荐使用 `wget` 方式运行：**

```bash
bash <(wget -qO- https://raw.githubusercontent.com/cheat0916/vps-init/master/vps-cheat.sh)
```

**或使用 `curl`：**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cheat0916/vps-init/master/vps-cheat.sh)
```

---

## 🧰 功能一览 / Features

| 类型 | 功能说明 |
|------|----------|
| 🔧 系统配置 | 自动识别用户名、修改主机名、修复 hosts |
| 🌍 软件源配置 | 智能识别系统并替换为国内镜像源（APT / YUM / DNF） |
| ⏰ 时间管理 | 设置系统时区、NTP 时间同步、支持手动选择城市 |
| 👤 用户管理 | 添加 / 删除用户、修改密码、授予/移除 sudo 权限 |
| 💾 软件安装 | 一键安装 WARP、Docker（官方推荐脚本） |
| 🚀 性能测试 | 集成 LemonBench，快速测试网络与性能 |
| 🧹 系统清理 | 清理缓存、无用日志、旧内核等 |
| 🌐 网络工具 | 网络状态检测、IP 地理位置、DNS 状态 |
| 🈶 多语言支持 | 中文 / English 动态切换 |
| 🎨 UI 美化 | 彩色输出、图标提示、UTF-8 兼容检测 |
| 📋 日志记录 | 所有关键操作自动写入日志文件 `/var/log/vps_xxx.log` |

---

## 🖥️ 支持系统 / Supported OS

- Debian / Ubuntu / CentOS / AlmaLinux / Rocky Linux 等主流发行版
- 自动适配软件包管理器：`apt` / `yum` / `dnf`

---

## 📁 项目结构 / Project Structure

| 路径 | 描述 |
|------|------|
| `vps-cheat.sh` | 主控制脚本（入口） |
| `lang/` | 多语言支持（中英文 JSON） |
| `modules/` | 各功能模块（user, time, source, warp, docker 等） |
| `utils/` | 公共函数（美化输出、检测函数、日志等） |
| `banner.png` | 项目封面图 |
| `README.md` | 项目说明文档 |

---

## 🧠 作者 / Author

- GitHub: [cheat0916](https://github.com/cheat0916)
- Telegram 项目组：**Cheat VPS Tools**

---

## ⚠️ 免责声明 / Disclaimer

> 本脚本仅供学习与研究用途，禁止用于任何非法用途。使用者需对使用本脚本所产生的后果自行承担全部责任。  
> This script is for educational purposes only. The author is not responsible for any consequences caused by its usage.

---

## 📌 未来计划 / Roadmap

- [ ] 支持自动开启 BBR / BBR Plus  
- [ ] 增加 SSH 加固与 fail2ban 防暴力破解  
- [ ] LNMP / 宝塔面板一键部署选项  
- [ ] 防火墙 / UFW / iptables 简易配置模块  
- [ ] WARP 多用户共享与授权管理  
- [ ] 自动模式支持（`--auto` 参数）

---

## 🌟 Star 支持 / Support

如果你觉得这个项目对你有帮助，欢迎点击右上角 `⭐ Star` 支持一下，谢谢！
```
