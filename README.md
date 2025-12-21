# dotfiles

> Personal dotfiles for a consistent terminal experience across **macOS / Linux / VPS**.

This repository contains my shell and terminal configuration, designed with the following goals:

- 🧠 **Consistency** across machines
- 🛡 **Safety** (no global tool overrides, no secrets)
- 🚀 **Developer-oriented** (Go-focused)
- 🌙 **Eye-friendly** and minimal

---

## ✨ Features

- zsh-based shell setup
- Cross-platform prompt powered by **starship**
- macOS / Linux conditional configuration
- Safe GNU tools usage (interactive only)
- Idempotent `install.sh` with automatic backups
- No secrets included (by design)

---

## 🖥 Supported Platforms

- macOS (Apple Silicon / Intel)
- Linux (Ubuntu / Debian / VPS)
- Remote SSH environments

> Tested primarily on macOS and Ubuntu.

---

## 📦 Requirements

Minimal requirements:

- `git`
- `zsh`
- `curl`

Optional but recommended:

- [`starship`](https://starship.rs/)
- GNU coreutils (macOS only, via Homebrew)
- zsh-autosuggestions & zsh-syntax-highlighting

---

## 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/simon-ding/.dotfiles.git  ~/.dotfiles
cd ~/.dotfiles
