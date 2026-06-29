using AmongUs.GameOptions;
using Il2CppInterop.Runtime.Attributes;
using MiraAPI.GameOptions;
using MiraAPI.Hud;
using MiraAPI.Roles;
using MiraAPI.Utilities;
using TouExtensionExample.Assets;
using TouExtensionExample.Buttons.Neutral;
using TouExtensionExample.Options.Roles.Neutral;
using TownOfUs.Roles;
using TownOfUs.Roles.Neutral;
using TownOfUs.Utilities;
using UnityEngine;
using Object = UnityEngine.Object;

namespace TouExtensionExample.Roles.Neutral;

public sealed class EmilRole(IntPtr cppPtr)
    : NeutralRole(cppPtr), ITownOfUsRole
{
    [HideFromIl2Cpp]
    public HashSet<byte> EatenPlayers { get; } = new();

    public string LocaleKey => "Emil";
    public string RoleName => "Emil";
    public string RoleDescription => "Eat everyone's body to win.";

    public string RoleLongDescription =>
        "You are slow and always hungry. Kill players and devour their bodies. " +
        "You don't have to be the killer, but you MUST eat every body. " +
        "Eaten bodies cannot be reported.";

    public Color RoleColor => TouExampleColors.Emil;
    public ModdedRoleTeams Team => ModdedRoleTeams.Custom;
    public RoleAlignment RoleAlignment => RoleAlignment.NeutralKilling;

    public CustomRoleConfiguration Configuration => new(this)
    {
        CanUseVent = OptionGroupSingleton<EmilOptions>.Instance.CanVent,
        GhostRole = (RoleTypes)RoleId.Get<NeutralGhostRole>(),
    };

    public bool HasImpostorVision => OptionGroupSingleton<EmilOptions>.Instance.ImpostorVision;

    [HideFromIl2Cpp]
    public bool WinConditionMet()
    {
        if (Player.HasDied())
        {
            return false;
        }

        var aliveOthers = Helpers.GetAlivePlayers().Count(p => p.PlayerId != Player.PlayerId);
        var remainingBodies = Object.FindObjectsOfType<DeadBody>().Count;

        return aliveOthers == 0 && remainingBodies == 0;
    }

    public void OffsetButtons()
    {
        var canVent = OptionGroupSingleton<EmilOptions>.Instance.CanVent;
        var kill = CustomButtonSingleton<EmilKillButton>.Instance;
        var eat = CustomButtonSingleton<EmilEatButton>.Instance;
        Reactor.Utilities.Coroutines.Start(MiscUtils.CoMoveButtonIndex(kill, !canVent));
        Reactor.Utilities.Coroutines.Start(MiscUtils.CoMoveButtonIndex(eat, !canVent));
    }

    public override void Initialize(PlayerControl player)
    {
        MiraAPI.Patches.Stubs.RoleBehaviourStubs.Initialize(this, player);
        EatenPlayers.Clear();

        if (Player.AmOwner)
        {
            OffsetButtons();
        }
    }

    public override void Deinitialize(PlayerControl targetPlayer)
    {
        MiraAPI.Patches.Stubs.RoleBehaviourStubs.Deinitialize(this, targetPlayer);
        EatenPlayers.Clear();
    }

    public override bool CanUse(IUsable usable)
    {
        if (!GameManager.Instance.LogicUsables.CanUse(usable, Player))
        {
            return false;
        }

        var console = usable.TryCast<Console>()!;
        return console == null || console.AllowImpostor;
    }

    public override bool DidWin(GameOverReason gameOverReason)
    {
        return WinConditionMet();
    }
}
