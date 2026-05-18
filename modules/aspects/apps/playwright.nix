_: {
  den.aspects.playwright = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.playwright-driver.browsers ];
        environment.variables = {
          PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
          PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
        };
      };

    homeManager =
      { config, lib, pkgs, ... }:
      lib.mkIf (config.programs.claude-code.enable or false) {
        programs.claude-code.mcpServers.playwright = {
          type = "stdio";
          command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
          args = [ ];
        };
      };
  };
}
