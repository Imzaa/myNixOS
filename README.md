# My NixOS Configuration

This repository contains my personal **NixOS configuration**. It is used to manage my Linux system, desktop environment, installed packages, user settings, and system preferences in a reproducible way.

## What is NixOS?

**NixOS** is a Linux distribution that is configured differently from most traditional Linux systems.

Instead of manually installing packages and changing settings one by one, NixOS allows the whole system configuration to be written in configuration files. This means the system can be rebuilt, restored, shared, or moved to another machine more easily.

In simple terms, this repository acts like a blueprint for my Linux setup.

## About This Setup

This configuration is focused on creating a custom desktop environment using **Niri**, **Quickshell**, and the **iNiR shell**.

My goal is to bring the iNiR setup, which was originally made for Arch-based systems, into NixOS. Since NixOS handles packages and system configuration differently from normal Linux distributions, some adjustments are needed to make everything work properly.

## Features

* NixOS system configuration
* Flake-based setup
* Home Manager configuration
* Niri Wayland compositor
* Quickshell-based desktop shell
* iNiR / illogical-impulse inspired interface
* Reproducible package and system setup
* Personal desktop customization

## Important Notice

Do **not** update iNiR using the iNiR interface.

Because this setup is managed through NixOS flakes, updates should be done using Nix commands instead.

### Update iNiR Source

```bash
cd ~/myNixOS
nix flake lock --update-input inir-src
sudo nixos-rebuild switch --flake .#myNix
```

### Rollback Update

If something breaks after updating, rollback the `flake.lock` file and rebuild the system:

```bash
cd ~/myNixOS
git checkout -- flake.lock
sudo nixos-rebuild switch --flake .#myNix
```

## Installation

This setup is intended for an already installed NixOS system.

```bash
nix shell nixpkgs#git -c git clone https://github.com/Imzaa/myNixOS.git ~/myNixOS
cd ~/myNixOS
./install-myNixOS.sh
```

After installation, rebuild the system using:

```bash
sudo nixos-rebuild switch --flake .#myNix
```

## Current Issues

Some features are not working properly yet:

1. Color Picker
2. Built-in Screen Recorder

These may be fixed in future updates as the setup becomes more stable on NixOS.

## Repository Purpose

This repository is mainly for personal use and learning. It helps me understand how NixOS works while also experimenting with porting an Arch-based desktop setup into a reproducible NixOS configuration.

It may also be useful for others who want to learn how NixOS flakes, Home Manager, Niri, Quickshell, and custom desktop shells can work together.

## Credits

Special thanks to the projects and developers that made this setup possible:

* [iNiR | snowarch](https://github.com/snowarch/iNiR) — Niri/Quickshell shell used in this setup
* [end-4](https://github.com/end-4) — original illogical-impulse work for Hyprland
* [Quickshell](https://git.outfoxxed.me/outfoxxed/quickshell) — framework powering the shell
* [Niri](https://github.com/YaLTeR/niri) — scrolling tiling Wayland compositor
* [NixOS](https://github.com/NixOS/nixpkgs) — base operating system and package set
* [Home Manager](https://github.com/nix-community/home-manager) — user configuration management

## Disclaimer

This repository only contains my personal NixOS configuration. All upstream projects remain under their respective authors and licenses.

This setup is still experimental, so some features may break or behave differently compared to the original Arch-based iNiR setup.
