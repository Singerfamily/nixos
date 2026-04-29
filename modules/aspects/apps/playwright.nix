_: {
  den.aspects.playwright.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.playwright-driver.browsers ];
      environment.variables = {
        PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
      };
    };
}
