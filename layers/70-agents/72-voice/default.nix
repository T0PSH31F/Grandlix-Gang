{ mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "agent-audio" ./asr-tts/agent-audio.nix)
  ];
}
