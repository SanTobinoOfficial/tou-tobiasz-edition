using MiraAPI.GameOptions;
using MiraAPI.Hud;
using MiraAPI.Keybinds;
using MiraAPI.Utilities.Assets;
using TouExtensionExample.Assets;
using TouExtensionExample.Options.Roles.Crewmate;
using TouExtensionExample.Roles.Crewmate;
using TownOfUs.Buttons;
using UnityEngine;

namespace TouExtensionExample.Buttons.Crewmate;

public sealed class JonaszDashButton : TownOfUsRoleButton<JonaszRole>
{
    public override string Name => "Dash";
    public override BaseKeybind Keybind => Keybinds.PrimaryAction;
    public override Color TextOutlineColor => TouExampleColors.Jonasz;
    public override float Cooldown => OptionGroupSingleton<JonaszOptions>.Instance.DashCooldown;
    public override LoadableAsset<Sprite> Sprite => ExampleNeutAssets.SentinelKillSprite;

    protected override void OnClick()
    {
        if (PlayerControl.LocalPlayer.Data.Role is not JonaszRole jonasz)
        {
            return;
        }

        jonasz.IsDashing = true;
        jonasz.DashTimer = OptionGroupSingleton<JonaszOptions>.Instance.DashDuration;
    }
}
