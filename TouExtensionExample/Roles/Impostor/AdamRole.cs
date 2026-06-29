using Il2CppInterop.Runtime.Attributes;
using MiraAPI.GameOptions;
using MiraAPI.Roles;
using TouExtensionExample.Options.Roles.Impostor;
using TownOfUs.Roles;
using UnityEngine;

namespace TouExtensionExample.Roles.Impostor;

public sealed class AdamRole(IntPtr cppPtr)
    : ImpostorRole(cppPtr), ITownOfUsRole
{
    [HideFromIl2Cpp] public bool SmokeActive { get; set; }
    [HideFromIl2Cpp] public float SmokeX { get; set; }
    [HideFromIl2Cpp] public float SmokeY { get; set; }
    [HideFromIl2Cpp] public float SmokeTimer { get; set; }

    public string LocaleKey => "Adam";
    public string RoleName => "Adam";
    public string RoleDescription => "Smoke the whole area to blind crewmates.";

    public string RoleLongDescription =>
        "You are an impostor with a smoke ability. " +
        "Activate your smoke to reduce the vision of all crewmates near you. " +
        "Use this to cover your kills or escape.";

    public Color RoleColor => TouExampleColors.Adam;
    public ModdedRoleTeams Team => ModdedRoleTeams.Impostor;
    public RoleAlignment RoleAlignment => RoleAlignment.ImpostorKilling;

    public CustomRoleConfiguration Configuration => new(this)
    {
        CanUseVent = true,
    };

    public override void Initialize(PlayerControl player)
    {
        MiraAPI.Patches.Stubs.RoleBehaviourStubs.Initialize(this, player);
        SmokeActive = false;
        SmokeTimer = 0f;
    }

    public override void Deinitialize(PlayerControl targetPlayer)
    {
        MiraAPI.Patches.Stubs.RoleBehaviourStubs.Deinitialize(this, targetPlayer);
        SmokeActive = false;
    }
}
