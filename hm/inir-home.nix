{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.programs.inir;
  inirSrc = inputs.inir-src;

  qmlPath = lib.concatStringsSep ":" [
    "${pkgs.kdePackages.kirigami}/lib/qt-6/qml"
    "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    "${pkgs.kdePackages.kirigami-addons}/lib/qt-6/qml"
    "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml"
    "${pkgs.qt6.qt5compat}/lib/qt-6/qml"
    "${pkgs.qt6.qtimageformats}/lib/qt-6/qml"
    "${pkgs.qt6.qtmultimedia}/lib/qt-6/qml"
    "${pkgs.qt6.qtquicktimeline}/lib/qt-6/qml"
  ];

  pluginPath = lib.concatStringsSep ":" [
    "${pkgs.kdePackages.kirigami}/lib/qt-6/plugins"
    "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/plugins"
    "${pkgs.kdePackages.kirigami-addons}/lib/qt-6/plugins"
    "${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/plugins"
    "${pkgs.qt6.qt5compat}/lib/qt-6/plugins"
    "${pkgs.qt6.qtimageformats}/lib/qt-6/plugins"
    "${pkgs.qt6.qtmultimedia}/lib/qt-6/plugins"
    "${pkgs.qt6.qtquicktimeline}/lib/qt-6/plugins"
  ];

  inirPython = pkgs.python3.withPackages (ps: with ps; [
    materialyoucolor
    pillow
    numpy
  ]);

  matugenAuto = pkgs.writeShellScriptBin "matugen" ''
    if [ "''${1:-}" = "image" ]; then
      has_index=0
      for arg in "$@"; do
        if [ "$arg" = "--source-color-index" ]; then
          has_index=1
        fi
      done

      if [ "$has_index" = "0" ]; then
        exec ${pkgs.matugen}/bin/matugen "$@" --source-color-index 0
      fi
    fi

    exec ${pkgs.matugen}/bin/matugen "$@"
  '';

  runtimePath = lib.makeBinPath [
    inirPython
    pkgs.bash
    pkgs.coreutils
    pkgs.util-linux
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.gawk
    pkgs.procps
    pkgs.xdg-utils
    pkgs.glib
    pkgs.kdePackages.kconfig
    pkgs.wlsunset
    pkgs.python3
    pkgs.yt-dlp
    pkgs.mpv
    pkgs.socat
    pkgs.niri
    pkgs.quickshell
    pkgs.kitty
    pkgs.foot
    pkgs.fish
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.cliphist
    pkgs.fuzzel
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.pamixer
    pkgs.pavucontrol
    pkgs.networkmanagerapplet
    pkgs.blueman
    pkgs.awww
    matugenAuto
    pkgs.imagemagick
    pkgs.jq
    pkgs.libnotify
  ];

  commonEnv = ''
    export XDG_CURRENT_DESKTOP=niri
    export XDG_SESSION_DESKTOP=niri
    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=qt6ct
    export QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor
    export QT_QUICK_CONTROLS_STYLE=Basic
    export QS_NO_RELOAD_POPUP=1
    unset QS_DROP_EXPENSIVE_FONTS

    export QML2_IMPORT_PATH="${qmlPath}:$QML2_IMPORT_PATH"
    export QML_IMPORT_PATH="${qmlPath}:$QML_IMPORT_PATH"
    export QT_PLUGIN_PATH="${pluginPath}:$QT_PLUGIN_PATH"

    export INIR_RUNTIME_DIR="$HOME/.local/share/inir"
    export INIR_PYTHON="${inirPython}/bin/python3"
    export PATH="$HOME/.local/bin:/etc/profiles/per-user/$USER/bin:${runtimePath}:$PATH"
  '';

  inirCli = pkgs.writeShellScriptBin "inir" ''
    ${commonEnv}

    REPO="$HOME/.local/share/inir"
    SCRIPT="$REPO/scripts/inir"

    if [ -f "$SCRIPT" ]; then
      exec ${pkgs.bash}/bin/bash "$SCRIPT" "$@"
    fi

    echo "iNiR CLI script not found at $SCRIPT"
    echo "Try resetting iNiR with:"
    echo "  rm -rf ~/.local/share/inir && sudo nixos-rebuild switch --flake ~/myNixOS#myNix"
    exit 1
  '';
in
{
  options.programs.inir = {
    enable = lib.mkEnableOption "iNiR Quickshell shell for Niri";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      quickshell
      qt6.qt5compat
      qt6.qtimageformats
      qt6.qtmultimedia
      qt6.qtquicktimeline
      qt6Packages.qt6ct

      kdePackages.kirigami
      kdePackages.kirigami-addons
      kdePackages.syntax-highlighting
      kdePackages.kconfig

      xwayland-satellite
      grim
      slurp
      wl-clipboard
      cliphist
      fuzzel

      brightnessctl
      playerctl
      pamixer
      pavucontrol
      networkmanagerapplet
      blueman

      awww
      matugenAuto
      imagemagick
      jq
      libnotify

      bash
      coreutils
      util-linux
      findutils
      gnugrep
      gnused
      gawk
      procps
      xdg-utils
      glib
      wlsunset
      python3
      yt-dlp
      mpv
      socat
      fish
      kitty
      foot

      material-symbols
      material-icons

      inirCli
    ];

    home.activation.setupINiR = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -eu

      RUNTIME="$HOME/.local/share/inir"

      SRC_MARKER="$RUNTIME/.nix-inir-src"
      NEW_SRC="${inirSrc}"

      # Refresh iNiR when missing OR when flake input changed.
      # This removes the need to manually rm -rf ~/.local/share/inir on update.
      if [ ! -f "$RUNTIME/shell.qml" ] || [ ! -f "$SRC_MARKER" ] || [ "$(cat "$SRC_MARKER" 2>/dev/null)" != "$NEW_SRC" ]; then
        rm -rf "$RUNTIME"
        mkdir -p "$RUNTIME"
        cp -R ${inirSrc}/. "$RUNTIME/"
        chmod -R u+w "$RUNTIME"
        echo "$NEW_SRC" > "$SRC_MARKER"
      fi

      # Quickshell runtime link.
      rm -rf "$HOME/.config/quickshell/inir"
      mkdir -p "$HOME/.config/quickshell"
      ln -sfn "$RUNTIME" "$HOME/.config/quickshell/inir"

      # Niri config link. iNiR owns Niri keybinds/config.
      rm -rf "$HOME/.config/niri"
      mkdir -p "$HOME/.config"
      ln -sfn "$RUNTIME/defaults/niri" "$HOME/.config/niri"

      # Niri autostart. No iNiR systemd service.
      mkdir -p "$RUNTIME/defaults/niri/config.d"
      cat > "$RUNTIME/defaults/niri/config.d/90-user-extra.kdl" <<'KDL'
spawn-at-startup "inir" "run"
KDL

      # Keep stock iNiR keybinds, but make any hardcoded launcher call our wrapper.
      if [ -f "$RUNTIME/defaults/niri/config.d/70-binds.kdl" ]; then
        sed -i \
          -e 's|"/home/[^"]*/\.local/bin/inir"|"inir"|g' \
          -e 's|"/etc/profiles/per-user/[^"]*/bin/inir"|"inir"|g' \
          "$RUNTIME/defaults/niri/config.d/70-binds.kdl"
      fi

      # Apply simple repo overrides.
      OVERRIDES="/home/imzaa/myNixOS/overrides"

      if [ -f "$OVERRIDES/keybinds.kdl" ]; then
        cp "$OVERRIDES/keybinds.kdl" \
           "$RUNTIME/defaults/niri/config.d/70-binds.kdl"
      fi

      if [ -f "$OVERRIDES/layout.kdl" ]; then
        cp "$OVERRIDES/layout.kdl" \
           "$RUNTIME/defaults/niri/config.d/20-layout-and-overview.kdl"
      fi

      if [ -f "$OVERRIDES/matugen.toml" ]; then
        mkdir -p "$RUNTIME/dots/.config/matugen"
        cp "$OVERRIDES/matugen.toml" \
           "$RUNTIME/dots/.config/matugen/config.toml"
      fi

      # Make switchwall use our Nix Python env.
      SW="$RUNTIME/scripts/colors/switchwall.sh"
      if [ -f "$SW" ]; then
        sed -i \
          's|_ii_python="$_ii_venv/bin/python3"|_ii_python="''${INIR_PYTHON:-$_ii_venv/bin/python3}"|' \
          "$SW" || true

        sed -i \
          's|\[\[ ! -x "$_ii_python" \]\] && _ii_python="python3"|[[ ! -x "$_ii_python" ]] \&\& _ii_python="$(command -v python3)"|' \
          "$SW" || true
      fi

      # Optional iNiR dot configs.
      for dir in fish foot kitty matugen; do
        if [ -d "$RUNTIME/dots/.config/$dir" ]; then
          rm -rf "$HOME/.config/$dir"
          ln -sfn "$RUNTIME/dots/.config/$dir" "$HOME/.config/$dir"
        fi
      done

      mkdir -p "$HOME/.local/state/quickshell/user/generated/wallpaper"
      mkdir -p "$HOME/.local/state/quickshell/user/generated/terminal"
      mkdir -p "$HOME/.cache/quickshell"

      touch "$HOME/.local/state/quickshell/user/gamemode_active"
      touch "$HOME/.local/state/quickshell/user/notepad.txt"

      if [ ! -f "$HOME/.local/state/quickshell/user/todo.json" ]; then
        echo "[]" > "$HOME/.local/state/quickshell/user/todo.json"
      fi

      if [ ! -f "$HOME/.local/state/quickshell/user/generated/colors.json" ]; then
        echo "{}" > "$HOME/.local/state/quickshell/user/generated/colors.json"
      fi

      # Make sure old iNiR systemd service cannot come back.
      rm -f "$HOME/.config/systemd/user/inir.service"
      rm -f "$HOME/.config/systemd/user/"*.wants/inir.service 2>/dev/null || true
    '';

    home.activation.linkMaterialIconFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.local/share/fonts/material-icons"

      find ${pkgs.material-symbols} ${pkgs.material-icons} \
        -type f \( -iname "*.ttf" -o -iname "*.otf" \) \
        -exec ln -sf {} "$HOME/.local/share/fonts/material-icons/" \;

      ${pkgs.fontconfig}/bin/fc-cache -f "$HOME/.local/share/fonts/material-icons" || true
    '';

    home.file.".local/bin/inir".source =
      "${inirCli}/bin/inir";

    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
      QT_QUICK_CONTROLS_STYLE = "Basic";
      QS_NO_RELOAD_POPUP = "1";
      QML2_IMPORT_PATH = qmlPath;
      QML_IMPORT_PATH = qmlPath;
      QT_PLUGIN_PATH = pluginPath;
      INIR_RUNTIME_DIR = "$HOME/.local/share/inir";
    };
  };
}
