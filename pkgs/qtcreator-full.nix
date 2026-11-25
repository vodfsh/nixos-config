{
  lib,
  symlinkJoin,
  buildEnv,
  makeWrapper,
  qt6,
  qtcreator,
  cmake,
  ninja,
  gcc,
  gdb,
  pkg-config,
  gnumake,
  libglvnd,
  libxkbcommon,
  wayland,
  libx11,
}: let
  qtModules = builtins.attrValues {
    inherit
      (qt6)
      qtbase
      qtdeclarative
      qtshadertools
      qtsvg
      qtimageformats
      qt5compat
      qtquicktimeline
      qtquick3d
      qtmultimedia
      qtwayland
      qtlanguageserver
      qttools
      ;
  };

  # System libs required by Qt6Gui's CMake dependency checks (OpenGL, EGL, XKB, X11, Wayland).
  # Only the default output is listed; the dev outputs come in via extraOutputsToInstall.
  sysLibs = [
    libglvnd
    libxkbcommon
    wayland
    libx11
  ];

  qtEnv = buildEnv {
    name = "qt6-creator-env";
    paths = qtModules ++ sysLibs;
    pathsToLink = ["/"];
    extraOutputsToInstall = ["dev" "bin"];
    # Qt modules overlap in /share (translations, cmake, mkspecs, etc.)
    ignoreCollisions = true;
  };

  tools = [cmake ninja gcc gdb pkg-config gnumake];
in
  symlinkJoin {
    pname = "qtcreator-full";
    inherit (qtcreator) version;

    paths = [qtcreator];
    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      wrapProgram $out/bin/qtcreator \
        --prefix PATH : "${lib.makeBinPath ([qtEnv] ++ tools)}" \
        --prefix CMAKE_PREFIX_PATH : "${qtEnv}" \
        --prefix PKG_CONFIG_PATH : "${qtEnv}/lib/pkgconfig:${qtEnv}/share/pkgconfig" \
        --prefix QT_PLUGIN_PATH : "${qtEnv}/${qt6.qtbase.qtPluginPrefix}" \
        --prefix QML_IMPORT_PATH : "${qtEnv}/${qt6.qtbase.qtQmlPrefix}"
    '';

    meta = {
      inherit (qtcreator.meta) description homepage license platforms;
      mainProgram = "qtcreator";
    };
  }
