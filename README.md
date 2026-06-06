# Credits

- [iNiR | snowarch](https://github.com/snowarch/iNiR): Niri/Quickshell shell used in this setup
- [end-4](https://github.com/end-4): original illogical-impulse work for Hyprland
- [Quickshell](https://git.outfoxxed.me/outfoxxed/quickshell): the framework powering this shell
- [Niri](https://github.com/YaLTeR/niri): the scrolling tiling Wayland compositor
- [NixOS](https://github.com/NixOS/nixpkgs): base operating system and package set
- [Home Manager](https://github.com/nix-community/home-manager): user configuration management

This repository only contains my personal NixOS configuration. All upstream projects remain under their respective authors and licenses.

Inir to NixOS- 

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

sudo nixos-generate-config --show-hardware-config > /tmp/hardware.nix
git clone https://github.com/Imzaa/myNixOS.git ~/myNixOS
cp /tmp/hardware.nix ~/myNixOS/modules/hosts/myNix/hardware.nix
cd ~/myNixOS
sudo nixos-rebuild switch --flake .#myNix

Things that doenst work for now 
1) Color Picker
2) Screen recorder (built in)

I just find out how powerful reproducability of NixOs is.. this is just something i do on my free times
