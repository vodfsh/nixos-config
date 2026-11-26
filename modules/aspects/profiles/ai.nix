{...}: {
  den.aspects.profiles.ai.nixos = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  };
}
