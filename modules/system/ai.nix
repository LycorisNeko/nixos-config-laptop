{ pkgs, ... }:

{
  # Ollama (model runner) - 支持 NVIDIA RTX 3070 CUDA 加速
  services.ollama = {
    enable = true;
    acceleration = "cuda";

    loadModels = [ "llama3.1:8b" ]; # auto-pulls on rebuild

    environmentVariables = {
      OLLAMA_NOANALYTICS = "1"; # disable telemetry
    };
  };
}
