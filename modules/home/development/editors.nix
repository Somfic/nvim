{ config, pkgs, ... }:

let
  # Create a patched VS Code with transparency support
  vscode-transparent = pkgs.stdenv.mkDerivation {
    pname = "vscode-transparent";
    version = "${pkgs.vscode.version}-transparent";

    src = pkgs.vscode;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -r $src/lib/vscode $out/lib/
      chmod -R u+w $out/lib/vscode

      # === main.js patches ===

      # Add enable-transparent-visuals flag
      sed -i 's/appendSwitch("disable-blink-features",o);const/appendSwitch("disable-blink-features",o);Oe.commandLine.appendSwitch("enable-transparent-visuals");const/' \
        $out/lib/vscode/resources/app/out/main.js || true

      # Make getBackgroundColor always return transparent
      sed -i 's/getBackgroundColor(){const e=this.getPreferredBaseTheme(),i=this.m();if(e===void 0||e===i){const s=this.f.getItem(Im,null);if(s)return s}switch(e??i){case At.VS:return a7;case At.HC_BLACK:return l7;case At.HC_LIGHT:return h7;default:return c7}}/getBackgroundColor(){return"#00000000"}/g' \
        $out/lib/vscode/resources/app/out/main.js || true

      # Set BrowserWindow to transparent
      sed -i 's/backgroundColor:r\.getBackgroundColor()/transparent:!0,backgroundColor:"#00000000"/' \
        $out/lib/vscode/resources/app/out/main.js || true

      # === workbench.desktop.main.js patches ===

      # Make WORKBENCH_BACKGROUND return transparent
      sed -i 's/function M3(i){switch(i.type){case Xo.LIGHT:return we.fromHex("#F3F3F3");case Xo.HIGH_CONTRAST_LIGHT:return we.fromHex("#FFFFFF");case Xo.HIGH_CONTRAST_DARK:return we.fromHex("#000000");default:return we.fromHex("#252526")}}/function M3(i){return we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Make saveWindowSplash save transparent background
      sed -i 's/background:we\.Format\.CSS\.formatHex(e\.getColor(us)||M3(e))/background:"rgba(0,0,0,0)"/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Force CSS addRule calls to use transparent
      sed -i 's/\.monaco-editor-background { background-color: ''${n}; }/.monaco-editor-background { background-color: transparent; }/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true
      sed -i 's/body { background-color: ''${t}; }/body { background-color: transparent; }/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true
      sed -i 's/\.monaco-workbench { background-color: ''${t}; }/.monaco-workbench { background-color: transparent; }/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # === workbench.js (splash screen) patches ===

      # Force splash screen backgrounds to transparent
      sed -i 's/n=o\.colorInfo\.editorBackground/n="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/n="#1E1E1E"/n="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/n="#FFFFFF"/n="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/n="#000000"/n="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true

      # === CSS overrides ===

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

      # Create wrapper script
      mkdir -p $out/bin
      makeWrapper $out/lib/vscode/bin/code $out/bin/code \
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
