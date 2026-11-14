{
  lib,
  symlinkJoin,
  makeWrapper,
  qt6,
  qtcreator,
  cmake,
  ninja,
  gcc,
  gdb,
  pkg-config,
  gnumake,
}: let
  qtModules = with qt6; [
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
  ];

  tools = [cmake ninja gcc gdb pkg-config gnumake];

  # Qt's tools (qmake, qml, qmllint, ...) can live in either output
  binDirs = lib.concatStringsSep ":" (
    map (p: "${lib.getBin p}/bin") (qtModules ++ tools)
    ++ map (p: "${lib.getDev p}/bin") qtModules
  );

  prefixPath = lib.concatStringsSep ":" (
    map (p: "${lib.getDev p}") qtModules ++ map (p: "${p}") qtModules
  );

  pluginPath = lib.makeSearchPath "lib/qt-6/plugins" qtModules;
  qmlPath = lib.makeSearchPath "lib/qt-6/qml" qtModules;
in
  symlinkJoin {
    name = "qtcreator-full-${qtcreator.version}";
    paths = [qtcreator];
    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      wrapProgram $out/bin/qtcreator \
        --suffix PATH : "${binDirs}" \
        --suffix CMAKE_PREFIX_PATH : "${prefixPath}" \
        --suffix QT_PLUGIN_PATH : "${pluginPath}" \
        --suffix QML_IMPORT_PATH : "${qmlPath}" \
        --suffix QML2_IMPORT_PATH : "${qmlPath}"
    '';

    meta.mainProgram = "qtcreator";
  }
