using MiraAPI.GameOptions;
using MiraAPI.GameOptions.Attributes;
using MiraAPI.Utilities;
using TouExtensionExample.Roles.Crewmate;

namespace TouExtensionExample.Options.Roles.Crewmate;

public sealed class JonaszOptions : AbstractOptionGroup<JonaszRole>
{
    public override string GroupName => "Jonasz";

    [ModdedNumberOption("JonaszSpeedMultiplier", 1f, 2f, 0.05f, MiraNumberSuffixes.Multiplier)]
    public float SpeedMultiplier { get; set; } = 1.25f;

    [ModdedNumberOption("JonaszDashSpeed", 1.5f, 4f, 0.25f, MiraNumberSuffixes.Multiplier)]
    public float DashSpeed { get; set; } = 2.5f;

    [ModdedNumberOption("JonaszDashDuration", 1f, 10f, 0.5f, MiraNumberSuffixes.Seconds)]
    public float DashDuration { get; set; } = 3f;

    [ModdedNumberOption("JonaszDashCooldown", 5f, 60f, 2.5f, MiraNumberSuffixes.Seconds)]
    public float DashCooldown { get; set; } = 20f;

    [ModdedNumberOption("JonaszBirdCooldown", 5f, 60f, 2.5f, MiraNumberSuffixes.Seconds)]
    public float BirdCooldown { get; set; } = 15f;

    [ModdedNumberOption("JonaszBirdRange", 0.5f, 5f, 0.25f, MiraNumberSuffixes.Multiplier)]
    public float BirdRange { get; set; } = 2f;

    [ModdedNumberOption("JonaszBirdRevealDuration", 1f, 10f, 0.5f, MiraNumberSuffixes.Seconds)]
    public float BirdRevealDuration { get; set; } = 3f;
}
