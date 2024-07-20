rec {
  filesIn = dir: (map (fname: dir + "/${fname}")
    (builtins.attrNames (builtins.readDir dir)));

  dirsIn = dir:
    inputs.nixpkgs.lib.filterAttrs (name: value: value == "directory")
    (builtins.readDir dir);

  fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));


  # Drill down through all subdirectories and return a list of all files
  allIn = dir:
    let
      dirs = dirsIn dir;
      files = filesIn dir;
    in
      files ++ (builtins.concatMap (d: allIn (dir + "/" + d)) dirs);
}