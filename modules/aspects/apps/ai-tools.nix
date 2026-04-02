{ den, ... }:
{
  # AI CLI tools aspect
  den.aspects.ai-tools.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        claude-code
        aider-chat
      ];
    };
}
