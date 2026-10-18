# Modular Immutable OS Image Builder

A lightweight, declarative configuration engine and build manager designed to output modular, immutable Debian system images using `live-build`, and `squashfs`.

## 🚀 Overview

Managing multiple static `live-build` configuration trees leads to configuration drift, duplicate maintenance overhead, and brittle build pipelines. This project decouples system layers—such as desktop environments, proprietary driver stacks, and system-level `/etc` configurations—into isolated, reusable modules.

The core engine dynamically parses modular configuration blueprints and generates clean, reproducible `live-build` output targets ready for execution.

## Key Features

* **Declarative Module Architecture:** Componentize complex system dependencies (e.g., Nvidia DKMS drivers, KDE/XFCE desktops, custom `/etc` configurations, and 32-bit multilib runtime environments like Steam) into decoupled, reusable modules.
* **Zero-Drift Generation:** Eliminates copied configuration trees by dynamically assembling build targets from a single source of truth.
* **Immutable & Atomic System Output:** Outputs compressed SquashFS root filesystems designed for read-only root execution, overlayfs persistence boundaries, and dynamic boot-time staging.
* **A/B Boot & Staging Ready:** Designed to work alongside bootloader configurations (like GRUB) for dual-image staging, testing, and zero-risk atomic rollbacks.
* **Headless-Ready Core:** Engineered with a clean separation between execution logic and UI wrappers, enabling seamless integration into headless CI/CD automation runners (GitHub Actions, GitLab CI).

## 🛠️ System Architecture & Workflow

1. **Modules (`/mods`):** Contain individual application manifests, `/etc` overlays, systemd `.mount` units, and `live-build` chroot hooks.
2. **Engine Execution:** The builder parses selected module manifests, resolves file overlays, and outputs a compiled `lb config` structure.
3. **Image Compilation:** Invokes standard Debian `live-build` tools to package the target environment into an immutable SquashFS root image.

## 📄 License

Distributed under the GPLv3 License. See `LICENSE` for more information.
