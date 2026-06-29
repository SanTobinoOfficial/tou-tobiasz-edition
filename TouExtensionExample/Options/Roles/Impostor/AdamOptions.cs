using MiraAPI.GameOptions;
using MiraAPI.GameOptions.Attributes;
using MiraAPI.Utilities;
using TouExtensionExample.Roles.Impostor;

namespace TouExtensionExample.Options.Roles.Impostor;

public sealed class AdamOptions : AbstractOptionGroup<AdamRole>
{
    public override string GroupName => "Adam";

    [ModdedNumberOption("AdamSmokeCooldown", 10f, 60f, 5f, MiraNumberSuffixes.Seconds)]
    public float SmokeCooldown { get; set; } = 25f;

    [ModdedNumberOption("AdamSmokeDuration", 3f, 20f, 1f, MiraNumberSuffixes.Seconds)]
    public float SmokeDuration { get; set; } = 8f;

    [ModdedNumberOption("AdamSmokeRadius", 1f, 15f, 0.5f, MiraNumberSuffixes.Multiplier)]
    public float SmokeRadius { get; set; } = 5f;

    [ModdedNumberOption("AdamVisionReduction", 0.05f, 0.8f, 0.05f, MiraNumberSuffixes.Multiplier)]
    public float VisionMultiplier { get; set; } = 0.2f;
}
