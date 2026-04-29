{ lib, ... }:
{
  den.aspects.azure-devops.nixos =
    { config, pkgs, ... }:
    {
      options.den.azureDevOps = {
        organization = lib.mkOption {
          type = lib.types.str;
          description = "Azure DevOps organization URL (e.g. https://dev.azure.com/<org>).";
        };
        project = lib.mkOption {
          type = lib.types.str;
          description = "Default Azure DevOps project name.";
        };
      };
      config = {
        environment.systemPackages = [ pkgs.azure-cli ];
        environment.variables = {
          AZURE_DEVOPS_ORG = config.den.azureDevOps.organization;
          AZURE_DEVOPS_PROJECT = config.den.azureDevOps.project;
        };
      };
    };
}
