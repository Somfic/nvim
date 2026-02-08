{ config, pkgs, ... }:

let
  # Create a patched VS Code with transparency support
  vscode-transparent = pkgs.stdenv.mkDerivation {
    pname = "vscode-transparent";
    version = "${pkgs.vscode.version}-patched25";

    src = pkgs.vscode;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -r $src/lib/vscode $out/lib/
      chmod -R u+w $out/lib/vscode

      # Patch main.js to add transparent visuals
      sed -i 's/appendSwitch("disable-blink-features",o);const/appendSwitch("disable-blink-features",o);Oe.commandLine.appendSwitch("enable-transparent-visuals");Oe.commandLine.appendSwitch("remote-debugging-port","9222");const/' \
        $out/lib/vscode/resources/app/out/main.js || true

      # Patch getBackgroundColor to always return transparent
      sed -i 's/getBackgroundColor(){const e=this.getPreferredBaseTheme(),i=this.m();if(e===void 0||e===i){const s=this.f.getItem(Im,null);if(s)return s}switch(e??i){case At.VS:return a7;case At.HC_BLACK:return l7;case At.HC_LIGHT:return h7;default:return c7}}/getBackgroundColor(){return"#00000000"}/g' \
        $out/lib/vscode/resources/app/out/main.js || true

      # Patch main.js to add transparent:true and transparent background to BrowserWindow
      sed -i 's/backgroundColor:r\.getBackgroundColor()/transparent:!0,backgroundColor:"#00000000"/' \
        $out/lib/vscode/resources/app/out/main.js || true

      # Patch workbench JS to make WORKBENCH_BACKGROUND return transparent
      sed -i 's/function M3(i){switch(i.type){case Xo.LIGHT:return we.fromHex("#F3F3F3");case Xo.HIGH_CONTRAST_LIGHT:return we.fromHex("#FFFFFF");case Xo.HIGH_CONTRAST_DARK:return we.fromHex("#000000");default:return we.fromHex("#252526")}}/function M3(i){return we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch editor.background color token to use transparent
      sed -i 's/q("editor\.background",{light:"#ffffff",dark:"#1E1E1E",hcDark:we\.black,hcLight:we\.white}/q("editor.background",{light:we.transparent,dark:we.transparent,hcDark:we.transparent,hcLight:we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch sideBar.background
      sed -i 's/q("sideBar\.background",{dark:"#252526",light:"#F3F3F3",hcDark:"#000000",hcLight:"#FFFFFF"}/q("sideBar.background",{dark:we.transparent,light:we.transparent,hcDark:we.transparent,hcLight:we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch activityBar.background
      sed -i 's/q("activityBar\.background",{dark:"#333333",light:"#2C2C2C",hcDark:"#000000",hcLight:"#FFFFFF"}/q("activityBar.background",{dark:we.transparent,light:we.transparent,hcDark:we.transparent,hcLight:we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch statusBar.background
      sed -i 's/q("statusBar\.background",{dark:"#007ACC",light:"#007ACC",hcDark:null,hcLight:null}/q("statusBar.background",{dark:we.transparent,light:we.transparent,hcDark:we.transparent,hcLight:we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch titleBar.activeBackground
      sed -i 's/q("titleBar\.activeBackground",{dark:"#3C3C3C",light:"#DDDDDD",hcDark:"#000000",hcLight:"#FFFFFF"}/q("titleBar.activeBackground",{dark:we.transparent,light:we.transparent,hcDark:we.transparent,hcLight:we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch tab.inactiveBackground
      sed -i 's/q("tab\.inactiveBackground",{dark:"#2D2D2D",light:"#ECECEC",hcDark:null,hcLight:null}/q("tab.inactiveBackground",{dark:we.transparent,light:we.transparent,hcDark:we.transparent,hcLight:we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch editorGroupHeader.tabsBackground
      sed -i 's/q("editorGroupHeader\.tabsBackground",{dark:"#252526",light:"#F3F3F3",hcDark:null,hcLight:null}/q("editorGroupHeader.tabsBackground",{dark:we.transparent,light:we.transparent,hcDark:we.transparent,hcLight:we.transparent}/' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch saveWindowSplash to always save transparent background
      sed -i 's/background:we\.Format\.CSS\.formatHex(e\.getColor(us)||M3(e))/background:"rgba(0,0,0,0)"/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch the runtime addRule calls that apply theme colors
      # Force monaco-editor-background to use transparent instead of theme color
      sed -i 's/\.monaco-editor-background { background-color: ''${n}; }/.monaco-editor-background { background-color: transparent; }/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Force body background to transparent
      sed -i 's/body { background-color: ''${t}; }/body { background-color: transparent; }/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Force monaco-workbench background to transparent
      sed -i 's/\.monaco-workbench { background-color: ''${t}; }/.monaco-workbench { background-color: transparent; }/g' \
        $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.js || true

      # Patch workbench.js - force shellBackground (editorBackground) to transparent
      sed -i 's/n=o\.colorInfo\.editorBackground/n="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true

      # Also patch the fallback values
      sed -i 's/n="#1E1E1E"/n="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/n="#FFFFFF"/n="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/n="#000000"/n="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true

      # Patch workbench.js (startup splash) - the main body background
      sed -i 's/background-color: ''${n}/background-color: transparent/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      # Patch other splash backgrounds
      sed -i 's/\.style\.backgroundColor=`''${r\.titleBarBackground}`/.style.backgroundColor="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/\.style\.backgroundColor=`''${r\.activityBarBackground}`/.style.backgroundColor="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/\.style\.backgroundColor=`''${r\.sideBarBackground}`/.style.backgroundColor="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/\.style\.backgroundColor=r\.statusBarBackground/.style.backgroundColor="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true
      sed -i 's/\.style\.backgroundColor=r\.statusBarNoFolderBackground/.style.backgroundColor="transparent"/g' \
        $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js || true

      # Patch workbench CSS to force transparent backgrounds on ALL elements
      echo '
/* Force transparency on everything */
html, body,
.monaco-workbench,
.monaco-workbench .part,
.monaco-workbench .part.editor,
.monaco-workbench .part.sidebar,
.monaco-workbench .part.panel,
.monaco-workbench .part.statusbar,
.monaco-workbench .part.titlebar,
.monaco-workbench .part.activitybar,
.monaco-workbench .part.auxiliarybar,
.monaco-workbench .editor,
.monaco-workbench .split-view-view,
.monaco-workbench .content,
.monaco-editor,
.monaco-editor-background,
.monaco-editor .overflow-guard,
.monaco-editor .margin,
.editor-group-container,
.editor-container,
.editor-instance,
.lines-content,
.view-lines,
.view-overlays,
.minimap,
.minimap-decorations-layer,
.decorationsOverviewRuler,
.pane-header,
.pane-body,
.monaco-list,
.monaco-list-rows,
.notifications-list-container,
.notification-toast,
.sidebar,
.composite,
.viewlet,
.explorer-viewlet,
.tabs-container,
.tab,
.tabs-and-actions-container,
.editor-group-container,
.title,
.panel,
.panel-header,
.terminal-wrapper,
.xterm,
.xterm-viewport,
.xterm-screen,
.tree-explorer-viewlet-tree-view,
.monaco-tree,
.monaco-tree-row {
  background: transparent !important;
  background-color: transparent !important;
}
' >> $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.css

      # Inject transparency forcing code at end of workbench.js (trusted script)
      cat >> $out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.js << 'ENDSCRIPT'

// Aggressive transparency enforcement using requestAnimationFrame
(function() {
  const forceTransparent = () => {
    document.querySelectorAll('*').forEach(el => {
      el.style.setProperty('background', 'transparent', 'important');
      el.style.setProperty('background-color', 'transparent', 'important');
    });
    requestAnimationFrame(forceTransparent);
  };

  // Start immediately and keep running
  if (document.body) {
    forceTransparent();
  } else {
    document.addEventListener('DOMContentLoaded', forceTransparent);
  }
})();
ENDSCRIPT

      # Create our own wrapper scripts that point to the patched version
      mkdir -p $out/bin
      makeWrapper $out/lib/vscode/bin/code $out/bin/code \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}

      # Copy share directory for desktop files etc
      if [ -d "$src/share" ]; then
        cp -r $src/share $out/
        chmod -R u+w $out/share
        # Update desktop file to point to our wrapper
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

  # Custom CSS for VSCodium transparency
  xdg.configFile."VSCodium/User/transparency.css".text = ''
    body {
      background-color: transparent !important;
    }
    .monaco-workbench {
      background-color: transparent !important;
    }
    .monaco-editor, .monaco-editor-background, .monaco-editor .margin {
      background-color: transparent !important;
    }
    .editor-group-container {
      background-color: transparent !important;
    }
    .split-view-view {
      background-color: transparent !important;
    }
    .title, .titlebar, .part.titlebar {
      background-color: rgba(22, 24, 26, 0.8) !important;
    }
    .sidebar, .part.sidebar {
      background-color: rgba(30, 33, 36, 0.7) !important;
    }
    .panel, .part.panel {
      background-color: rgba(30, 33, 36, 0.7) !important;
    }
    .statusbar, .part.statusbar {
      background-color: rgba(22, 24, 26, 0.8) !important;
    }
  '';

  home.packages = with pkgs; [
    github-desktop
  ];
}