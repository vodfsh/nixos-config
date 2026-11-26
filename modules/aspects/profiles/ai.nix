{...}: {
  den.aspects.profiles.ai.nixos = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama-cuda;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "16384";
      };
    };
  };
}
