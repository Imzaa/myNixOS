{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };

    environment.systemPackages = with pkgs; [
      kitty
      firefox
      nautilus
      xwayland-satellite

      # screenshots
      grim
      slurp
      wl-clipboard

      # simple clipboard history popup
      cliphist
      fuzzel
    ];
  };

  perSystem = { pkgs, lib, self', ... }:
  let
    cliphistWatch = pkgs.writeShellScriptBin "cliphist-watch" ''
      ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store &
      ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store &
      wait
    '';

    cliphistPick = pkgs.writeShellScriptBin "cliphist-pick" ''
      ${pkgs.cliphist}/bin/cliphist list \
        | ${pkgs.fuzzel}/bin/fuzzel --dmenu \
            --prompt="Clipboard > " \
            --width=60 \
            --lines=12 \
            --background=11111bff \
            --text-color=cdd6f4ff \
            --selection-color=313244ff \
            --selection-text-color=cdd6f4ff \
            --border-color=89b4faff \
        | ${pkgs.cliphist}/bin/cliphist decode \
        | ${pkgs.wl-clipboard}/bin/wl-copy
    '';
  in {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;

      settings = {
          spawn-at-startup = [
          (lib.getExe cliphistWatch)
        ];

        hotkey-overlay.skip-at-startup = _: {};

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard.xkb.layout = "us";

        layout = {
          gaps = 5;

          always-center-single-column = _: {};

          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
            { proportion = 0.8; }
          ];

          preset-window-heights = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];

          default-column-width = {
            proportion = 0.5;
          };
        };

        binds = {
          "Mod+Return".spawn = [ (lib.getExe pkgs.kitty) ];

          "Mod+B".spawn = [ (lib.getExe pkgs.firefox) ];

          "Mod+Space".spawn-sh =
            "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";

          "Mod+E".spawn = [ (lib.getExe pkgs.nautilus) ];

          "Mod+Shift+S".spawn-sh =
            ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';

          "Mod+V".spawn = [ (lib.getExe cliphistPick) ];
          "Mod+Tab".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call dashboard toggle";
          

          "Mod+Slash".show-hotkey-overlay = _: {};

          "Mod+Q".close-window = _: {};

          "Mod+Left".focus-column-left = _: {};
          "Mod+Right".focus-column-right = _: {};
          "Mod+Up".focus-window-up = _: {};
          "Mod+Down".focus-window-down = _: {};

          "Mod+R".switch-preset-column-width = _: {};
          "Mod+Shift+R".switch-preset-window-height = _: {};

          "Mod+Shift+Left".move-column-left = _: {};
          "Mod+Shift+Right".move-column-right = _: {};
          "Mod+Shift+Up".move-window-up = _: {};
          "Mod+Shift+Down".move-window-down = _: {};

          "Mod+WheelScrollDown".focus-workspace-down = _: {};
          "Mod+WheelScrollUp".focus-workspace-up = _: {};
          "Mod+Shift+WheelScrollDown".focus-column-right = _: {};
          "Mod+Shift+WheelScrollUp".focus-column-left = _: {};

          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;

          "Mod+Shift+1".move-window-to-workspace = 1;
          "Mod+Shift+2".move-window-to-workspace = 2;
          "Mod+Shift+3".move-window-to-workspace = 3;
          "Mod+Shift+4".move-window-to-workspace = 4;
          "Mod+Shift+5".move-window-to-workspace = 5;

          "Mod+F".maximize-column = _: {};
          "Mod+Shift+F".fullscreen-window = _: {};
          "Mod+T".toggle-window-floating = _: {};

          "Mod+Shift+E".quit = _: {};
        };
      };
    };
  };
}
