{...}: {
  den.aspects.profiles.ai.nixos = {pkgs, ...}: let
    llama = pkgs.unstable.llama-cpp.override {cudaSupport = true;};
    server = "${llama}/bin/llama-server";

    swapConfig = pkgs.writeText "llama-swap.yaml" (builtins.toJSON {
      models = {
        main = {
          cmd = "${server} --port \${PORT} -hf unsloth/Qwen3.5-9B-GGUF:Q4_K_M -c 65536 -n 8192 --n-gpu-layers auto --fit on --flash-attn on --cache-type-k q8_0 --cache-type-v q8_0 --jinja";
          ttl = 300; # unload after 5 min idle
        };
        small = {
          cmd = "${server} --port \${PORT} -hf Qwen/Qwen2.5-1.5B-Instruct-GGUF:Q4_K_M -ngl 0 -t 2 -c 4096 -n 256 --jinja";
          ttl = 300;
        };
      };
      # let main and small be loaded at the same time instead of swapping
      groups.both = {
        swap = false;
        members = ["main" "small"];
      };
    });
  in {
    environment.systemPackages = [llama];

    systemd.user.services.llama-swap = {
      description = "llama-swap";
      wantedBy = ["default.target"];
      serviceConfig = {
        Restart = "on-failure";
        ExecStart = "${pkgs.llama-swap}/bin/llama-swap --config ${swapConfig} --listen 127.0.0.1:11435";
      };
    };
  };
}
