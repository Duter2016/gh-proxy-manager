# gh-proxy-manager

[中文说明](#中文) | [English](#english)

---

<a id="中文"></a>
## 中文

管理 Arch Linux 下 GitHub 下载加速的小工具（yay/makepkg 与 git clone 双通道）。

### 解决什么问题

`yay -Syu` 升级 AUR 软件时，遇到 PKGBUILD 里写死的 `https://github.com/.../releases/download/...`
源，直连极慢甚至超时。本工具通过 makepkg DLAGENT 覆盖与 git `insteadOf` 规则，
让所有 GitHub 源自动套加速前缀，并提供图形界面随时开关、换站、测速。

### 特性

- ✅ yay/makepkg 加速：独立 `/etc/makepkg.conf.d/99-gh-proxy.conf`，不碰主配置
- ✅ git clone 加速：一键启停全局 `insteadOf` 规则
- ✅ 备选加速站列表：添加 / 删除 / 切换生效，内置批量连通性测试
- ✅ 开关零残留：关闭即恢复官方直连，卸载时自动校验
- ✅ GUI（yad）+ CLI 双模式；单次提权、幂等写入
- ⚠️ 仅对 github.com / raw.githubusercontent.com / codeload.github.com 生效

### 安装

```bash
git clone https://github.com/Duter2016/gh-proxy-manager.git
cd gh-proxy-manager
makepkg -f
sudo pacman -U gh-proxy-manager-*-any.pkg.tar.zst
```

依赖：`bash curl git`；可选 `yad`（GUI）、`polkit`。

### 使用（图形界面）

应用菜单「GitHub 下载加速管理」或直接运行 `gh-proxy-manager`：

- 勾选要开启的加速通道，确认加速地址，点「应用」
- 「备选地址…」里可添加/删除/切换加速站，并批量测试连通性

### 使用（命令行）

```bash
gh-proxy-manager on        # 开启 yay/makepkg 加速
gh-proxy-manager off       # 关闭
gh-proxy-manager git-on    # 开启 git clone 加速
gh-proxy-manager url <前缀>    # 更换加速地址
gh-proxy-manager add <URL>     # 备选列表增加
gh-proxy-manager use <URL>     # 切换生效
gh-proxy-manager test      # 连通性测试
gh-proxy-manager status    # 当前状态
gh-proxy-manager log       # 查看调试日志
```

### 终端随手下载（可选）

除了 makepkg/git 自动加速外，还提供下载子命令，手动 curl GitHub 链接时自动套用当前生效的加速前缀：

```bash
gh-proxy-manager get https://github.com/xxx/yyy/releases/download/v1/file.tar.gz
gh-proxy-manager get <url> -H "Authorization: token xxx"   # 额外参数原样传给 curl
```

也可以在 `.bashrc` 里加一个更顺手的函数：

```bash
ghcurl(){
  local p url="$1"
  p="$(cat /etc/gh-proxy/prefix 2>/dev/null)"
  [ "$url" != "${url/github.com/}" ] && [ -n "$p" ] && url="${p}${url}"
  shift
  curl -L -O "$@" "$url"
}
# 之后: ghcurl <github url>
```

未开启加速或非 github 链接时自动退化为普通 curl 下载。

### 卸载

```bash
sudo pacman -R gh-proxy-manager
/var/lib/gh-proxy-manager/uninstall-cleanup.sh   # 清理运行时文件
```

### 排错

任何功能异常先看 `~/.config/gh-proxy-manager/debug.log`——每步操作的状态、
返回码、原始输入都会记录在案。提 issue 时请附上该日志。

---

<a id="english"></a>
## English

A tiny manager for GitHub download acceleration on Arch Linux (both yay/makepkg
sources and git clone).

### Why

When `yay -Syu` hits an AUR package whose PKGBUILD hardcodes a
`https://github.com/.../releases/download/...` source, direct downloads are
painfully slow in some networks. This tool overrides the makepkg DLAGENT and
manages git `insteadOf` rules, so every GitHub URL is automatically routed
through your favourite acceleration mirror — with a GUI to toggle it on/off,
switch mirrors and run speed tests.

### Features

- yay/makepkg acceleration via `/etc/makepkg.conf.d/99-gh-proxy.conf` (main config untouched)
- One-click global `insteadOf` rule for git clone
- Mirror pool: add / remove / switch active mirror, with batch connectivity tests
- Clean on/off: disabling restores official connections; uninstall leaves nothing behind
- GUI (yad) + CLI; single privilege escalation per apply, idempotent writes
- Only rewrites `github.com`, `raw.githubusercontent.com`, `codeload.github.com`

### Install

```bash
git clone https://github.com/Duter2016/gh-proxy-manager.git
cd gh-proxy-manager && makepkg -f
sudo pacman -U gh-proxy-manager-*-any.pkg.tar.zst
```

Depends: `bash curl git`; optional: `yad`, `polkit`.

### CLI quick start

```bash
gh-proxy-manager on          # enable makepkg/yay acceleration
gh-proxy-manager git-on      # enable git clone acceleration
gh-proxy-manager url https://<mirror>/   # change prefix
gh-proxy-manager test        # connectivity check
gh-proxy-manager status      # current state
```

GUI: run `gh-proxy-manager` or find “GitHub 下载加速管理” in your app menu.

### Ad-hoc terminal downloads

Besides makepkg/git, a `get` subcommand rewrites URLs for plain curl downloads:

```bash
gh-proxy-manager get <github-url>        # uses active mirror if acceleration is on
```

Or drop this helper into your `.bashrc`:

```bash
ghcurl(){
  local p url="$1"
  p="$(cat /etc/gh-proxy/prefix 2>/dev/null)"
  [ "$url" != "${url/github.com/}" ] && [ -n "$p" ] && url="${p}${url}"
  shift
  curl -L -O "$@" "$url"
}
# then: ghcurl <github-url>
```

It degrades to plain curl when acceleration is off or the URL is not GitHub.

### Uninstall

```bash
sudo pacman -R gh-proxy-manager
/var/lib/gh-proxy-manager/uninstall-cleanup.sh
```

### Troubleshooting

Everything is logged to `~/.config/gh-proxy-manager/debug.log`. Attach it when
opening an issue.
