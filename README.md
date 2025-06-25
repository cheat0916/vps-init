<p align="center">
  <img src="https://raw.githubusercontent.com/cheat0916/vps-init/master/banner.png" alt="Cheat VPS Init Banner" width="100%">
</p>

<h1 align="center">Cheat VPS Init Toolkit</h1>
<p align="center">🚀 VPS 初始化脚本工具 - 一键配置、自动安装、中文/English 多语言支持</p>

<p align="center">
  <img src="https://img.shields.io/github/repo-size/cheat0916/vps-init" />
  <img src="https://img.shields.io/github/last-commit/cheat0916/vps-init" />
  <img src="https://img.shields.io/github/license/cheat0916/vps-init" />
  <img src="https://img.shields.io/github/stars/cheat0916/vps-init?style=social" />
</p>

---

## 📥 快速开始 / Quick Start

在你的 VPS 上运行以下命令：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/cheat0916/vps-init/master/vps-cheat.sh)
```

## 🧰 功能说明 / Features

- ✅ 检测当前用户名并修复主机名 hosts  
- ✅ 检查并修复系统软件源（支持 Debian / Ubuntu / CentOS / AlmaLinux）  
- ✅ 软件包更新提示并选择是否执行  
- ✅ 清理系统缓存和垃圾  
- ✅ 一键安装 WARP（调用 fscarmen 脚本）  
- ✅ 一键安装 Docker（官方推荐脚本）  
- ✅ VPS 性能测试（集成 LemonBench）  
- 🌐 网络连接状态实时检测  
- 🌐 支持中文 / English 界面切换  
- 🎨 彩色输出增强可读性  
- 🧑‍💻 支持 curl / wget / sudo，建议以 root 用户运行  

---

## 🖥️ 支持系统 / Supported OS

- Debian / Ubuntu / CentOS / AlmaLinux / Rocky Linux 等主流发行版  
- 自动检测并适配 `apt` / `yum` / `dnf` 包管理器  

---

## 📁 文件结构 / Files

| 文件名         | 说明                        |
|----------------|-----------------------------|
| `vps-cheat.sh` | 主脚本文件（可一键运行）    |
| `README.md`    | 项目说明文档                |
| `banner.png`   | 项目顶部封面图              |

---

## 🧠 作者 / Author

- GitHub: [cheat0916](https://github.com/cheat0916)  
- Telegram 项目组：**Cheat VPS Tools**

---

## ⚠️ 免责声明 / Disclaimer

> 本项目仅用于合法合规用途，禁止用于任何违法行为。使用本脚本造成的任何风险与后果，作者概不负责。  
> This script is intended for lawful use only. Use at your own risk.

---

## 📌 未来功能计划 / TODO

- [ ] BBR 自动安装支持  
- [ ] SSH 安全强化配置  
- [ ] LNMP 或宝塔面板一键部署  
- [ ] 防火墙设置与 Fail2ban  
- [ ] 多用户 WARP 授权支持  

---

> 🙏 如果你觉得本项目有帮助，请点击 Star ⭐ 支持我持续更新！
