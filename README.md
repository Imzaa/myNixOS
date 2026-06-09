# My NixOS Configuration

This repository contains my personal NixOS configuration files. It is used to manage my Linux system setup, desktop environment, installed packages, and system preferences in a reproducible way.

I'm aiming to import iNiR installation that were built for arch for NixOS, since it had different way of handling stuff compared to normal linux distro.

# IMPORTANT!! 
Dont Update via Inir Interface... use this Command
cd ~/myNixOS
nix flake lock --update-input inir-src
sudo nixos-rebuild switch --flake .#myNix

To rollback
cd ~/myNixOS

git checkout -- flake.lock
sudo nixos-rebuild switch --flake .#myNix

# iNSTALLATION
(Installed NixOS Only)
nix shell nixpkgs#git -c git clone https://github.com/Imzaa/myNixOS.git ~/myNixOS
cd ~/myNixOS
./install-myNixOS.sh

Things that doenst work for now 
1) Color Picker
2) Screen recorder (built in)

# Credits

- [iNiR | snowarch](https://github.com/snowarch/iNiR): Niri/Quickshell shell used in this setup
- [end-4](https://github.com/end-4): original illogical-impulse work for Hyprland
- [Quickshell](https://git.outfoxxed.me/outfoxxed/quickshell): the framework powering this shell
- [Niri](https://github.com/YaLTeR/niri): the scrolling tiling Wayland compositor
- [NixOS](https://github.com/NixOS/nixpkgs): base operating system and package set
- [Home Manager](https://github.com/nix-community/home-manager): user configuration management

This repository only contains my personal NixOS configuration. All upstream projects remain under their respective authors and licenses.
