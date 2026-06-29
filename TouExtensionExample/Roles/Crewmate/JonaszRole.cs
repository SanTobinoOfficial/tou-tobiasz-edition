using AmongUs.GameOptions;
using Il2CppInterop.Runtime.Attributes;
using MiraAPI.GameOptions;
using MiraAPI.Hud;
using MiraAPI.Patches.Stubs;
using MiraAPI.Roles;
using MiraAPI.Utilities;
using Reactor.Utilities;
using TouExtensionExample.Assets;
using TouExtensionExample.Buttons.Crewmate;
using TouExtensionExample.Options.Roles.Crewmate;
using TownOfUs.Roles;
using TownOfUs.Utilities;
using UnityEngine;

namespace TouExtensionExample.Roles.Crewmate;

public sealed class JonaszRole(IntPtr cppPtr)
    : CrewmateRole(cppPtr), ITownOfUsRole
{
    [HideFromIl2Cpp]
    public bool IsDashing { get; set; }

    [HideFromIl2Cpp]
    public float DashTimer { get; set; }

    public string LocaleKey => "Jonasz";
    public string RoleName => "Jonasz";
    public string RoleDescription => "Fast and agile. Use birds to investigate and dash to escape.";

    public string RoleLongDescription =>
        "You are small and fast. Send your birds to check if a nearby player is safe. " +
        "Use Dash to get a burst of speed and escape danger like an obby pro.";

    public Color RoleColor => TouExampleColors.Jonasz;
    public ModdedRoleTeams Team => ModdedRoleTeams.Crewmate;
    public RoleAlignment RoleAlignment => RoleAlignment.CrewmateInvestigative;

    public CustomRoleConfiguration Configuration => new(this)
    {
        CanUseVent = false,
    };

    public bool HasImpostorVision => false;

    public void OffsetButtons()
    {
        var dash = CustomButtonSingleton<JonaszDashButton>.Instance;
        var bird = CustomButtonSingleton<JonaszBirdButton>.Instance;
        Coroutines.Start(MiscUtils.CoMoveButtonIndex(dash, true));
        Coroutines.Start(MiscUtils.CoMoveButtonIndex(bird, true));
    }

    public override void Initialize(PlayerControl player)
    {
        RoleBehaviourStubs.Initialize(this, player);
        IsDashing = false;
        DashTimer = 0f;

        if (Player.AmOwner)
        {
            OffsetButtons();
        }
    }

    public override void Deinitialize(PlayerControl targetPlayer)
    {
        RoleBehaviourStubs.Deinitialize(this, targetPlayer);
        IsDashing = false;
        DashTimer = 0f;
    }
}
