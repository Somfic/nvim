{ config, pkgs, ... }:

let
  # Override github-desktop to patch transparency BEFORE auto-patchelf runs
  github-desktop-transparent = pkgs.github-desktop.overrideAttrs (old: {
    pname = "github-desktop-transparent";

    # Patch main.js and renderer.css after unpack, before auto-patchelf
    postUnpack = (old.postUnpack or "") + ''
      # Patch main.js — enable BrowserWindow transparency
      perl -pi -e 's/backgroundColor:"#fff"/transparent:!0,backgroundColor:"#00000000"/' \
        $TMP/github-desktop/usr/lib/github-desktop/resources/app/main.js

      # Patch renderer.css — transparent backgrounds + hide title bar
      cat >> $TMP/github-desktop/usr/lib/github-desktop/resources/app/renderer.css << 'CSSEOF'

/* Transparency overrides — use high specificity to beat body.theme-dark */
:root, body.theme-dark, body.theme-light {
  --background-color: transparent !important;
  --box-background-color: transparent !important;
  --box-alt-background-color: transparent !important;
  --tab-bar-background-color: transparent !important;
  --tab-bar-hover-background-color: rgba(255, 255, 255, 0.05) !important;
  --win32-title-bar-background-color: transparent !important;
  --toolbar-background-color: transparent !important;
  --box-border-color: rgba(255, 255, 255, 0.15) !important;
  --box-border-contrast-color: rgba(255, 255, 255, 0.2) !important;
  --toolbar-border-color: rgba(255, 255, 255, 0.15) !important;
  --diff-border-color: rgba(255, 255, 255, 0.15) !important;
  --base-border: 1px solid rgba(255, 255, 255, 0.15) !important;
  --contrast-border: 1px solid rgba(255, 255, 255, 0.2) !important;
  --diff-gutter-background-color: transparent !important;
  --diff-gutter-color: transparent !important;
  --diff-empty-row-background-color: transparent !important;
  --diff-empty-row-gutter-background-color: transparent !important;
  --diff-hunk-background-color: transparent !important;
  --diff-hunk-gutter-background-color: transparent !important;
  --diff-add-background-color: rgba(46, 160, 67, 0.15) !important;
  --diff-add-gutter-background-color: rgba(46, 160, 67, 0.2) !important;
  --diff-add-inner-background-color: rgba(46, 160, 67, 0.3) !important;
  --diff-delete-background-color: rgba(248, 81, 73, 0.15) !important;
  --diff-delete-gutter-background-color: rgba(248, 81, 73, 0.2) !important;
  --diff-delete-inner-background-color: rgba(248, 81, 73, 0.3) !important;
}
html, body, #content, #desktop-app-title-bar {
  background: transparent !important;
  background-color: transparent !important;
}
#desktop-app-title-bar,
#app-menu-bar {
  display: none !important;
}
CSSEOF
    '';

    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.perl ];
  });

  # Create a patched VS Code with transparency support
  vscode-transparent = pkgs.stdenv.mkDerivation {
    pname = "vscode-transparent";
    version = "${pkgs.vscode.version}-transparent";

    src = pkgs.vscode;

    nativeBuildInputs = [ pkgs.makeWrapper pkgs.perl ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -r $src/lib/vscode $out/lib/
      chmod -R u+w $out/lib/vscode

      # Patch main.js (perl handles long lines, sed does not)
      # 1. BrowserWindow transparent flag
      perl -pi -e 's/backgroundColor:[^,}]*/transparent:!0,backgroundColor:"#00000000"/' \
        $out/lib/vscode/resources/app/out/main.js

      # 2. getBackgroundColor() → return transparent immediately
      perl -pi -e 's/getBackgroundColor\(\)\{/getBackgroundColor(){return"#00000000";/' \
        $out/lib/vscode/resources/app/out/main.js

      # 3. setBackgroundColor("#FFFFFF") → transparent
      perl -pi -e 's/setBackgroundColor\("#FFFFFF"\)/setBackgroundColor("#00000000")/' \
        $out/lib/vscode/resources/app/out/main.js

      # 4. updateBackgroundColor() → no-op (prevents theme from overwriting transparent bg)
      perl -pi -e 's/updateBackgroundColor\(e,t\)\{/updateBackgroundColor(e,t){return;/' \
        $out/lib/vscode/resources/app/out/main.js

      # Patch workbench.js — splash screen background-color variable → transparent
      perl -pi -e 's/background-color: \$\{l\}/background-color: transparent/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js

      # Patch workbench.desktop.main.js — BO() function returns opaque workbench bg
      # Replace known dark/light defaults with transparent
      perl -pi -e 's/#252526/#00000000/g; s/#F3F3F3/#00000000/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js

      # CSS overrides for transparency
      echo '
/* Transparency overrides */
html, body,
.monaco-workbench,
.monaco-workbench .part,
.monaco-editor,
.monaco-editor-background,
.overflow-guard,
.lines-content,
.view-lines,
.editor-container,
.split-view-view {
  background: transparent !important;
  background-color: transparent !important;
}
' >> $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.css

      # Create wrapper script with transparent visuals flag
      mkdir -p $out/bin
      makeWrapper $out/lib/vscode/bin/code $out/bin/code \
        --set ELECTRON_EXTRA_LAUNCH_ARGS "--enable-transparent-visuals" \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}

      # Copy share directory for desktop files
      if [ -d "$src/share" ]; then
        cp -r $src/share $out/
        chmod -R u+w $out/share
        for f in $out/share/applications/*.desktop; do
          if [ -f "$f" ]; then
            substituteInPlace "$f" --replace-quiet "$src" "$out" || true
          fi
        done
      fi

      runHook postInstall
    '';

    meta = pkgs.vscode.meta;
  };
in
{
  programs = {
    vscode = {
      enable = true;
      package = vscode-transparent;
      mutableExtensionsDir = true;
    };

    kitty = {
      enable = true;
      settings = { window_padding_width = 14; };
    };
  };

  home.packages = [
    github-desktop-transparent
  ];
}
