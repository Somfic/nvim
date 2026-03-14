{ config, pkgs, ... }:

let
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
        --add-flags "--enable-transparent-visuals" \
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

  home.packages = with pkgs; [
    github-desktop
  ];
}
