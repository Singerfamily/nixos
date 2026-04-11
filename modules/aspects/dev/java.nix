{ den, ... }:
{
  den.aspects.dev.java = {
    includes = [ den.aspects.dev ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          jdk
          gradle
          maven
          google-java-format
          jdt-language-server
        ];
        home.sessionVariables = {
          JDTLS_PATH = "${pkgs.jdt-language-server}/share/java";
        };
      };
  };
}
