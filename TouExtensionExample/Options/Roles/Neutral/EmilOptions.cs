using MiraAPI.GameOptions;
using MiraAPI.GameOptions.Attributes;
using MiraAPI.GameOptions.OptionTypes;
using MiraAPI.Utilities;
using TouExtensionExample.Roles.Neutral;

namespace TouExtensionExample.Options.Roles.Neutral;

public sealed class EmilOptions : AbstractOptionGroup<EmilRole>
{
    public override string GroupName => "Emil";

    [ModdedNumberOption("EmilKillCooldown", 5f, 120f, 2.5f, MiraNumberSuffixes.Seconds)]
    public float KillCooldown { get; set; } = 30f;

    [ModdedNumberOption("EmilEatCooldown", 2.5f, 60f, 2.5f, MiraNumberSuffixes.Seconds)]
    public float EatCooldown { get; set; } = 5f;

    [ModdedNumberOption("EmilEatRange", 0.5f, 5f, 0.25f, MiraNumberSuffixes.Multiplier)]
    public float EatRange { get; set; } = 1.5f;

    [ModdedNumberOption("EmilSpeedMultiplier", 0.25f, 1f, 0.05f, MiraNumberSuffixes.Multiplier)]
    public float SpeedMultiplier { get; set; } = 0.75f;

    [ModdedToggleOption("EmilImpostorVision")]
    public bool ImpostorVision { get; set; }

    [ModdedToggleOption("EmilCanVent")]
    public bool CanVent { get; set; }
}
