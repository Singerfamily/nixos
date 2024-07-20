{myLib, ...}: with myLib; {
  imports = [
    filesIn ./apps
  ];
}