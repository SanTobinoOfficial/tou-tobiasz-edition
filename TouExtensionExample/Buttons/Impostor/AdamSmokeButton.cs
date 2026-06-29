using MiraAPI.GameOptions;
using MiraAPI.Keybinds;
using MiraAPI.Utilities.Assets;
using TouExtensionExample.Modules;
using TouExtensionExample.Options.Roles.Impostor;
using TouExtensionExample.Roles.Impostor;
using TownOfUs.Buttons;
using UnityEngine;

namespace TouExtensionExample.Buttons.Impostor;

public sealed class AdamSmokeButton : TownOfUsRoleButton<AdamRole>
{
    public override string Name => "Dym";
    public override BaseKeybind Keybind => Keybinds.SecondaryAction;
    public override Color TextOutlineColor => TouExampleColors.Adam;
    public override float Cooldown => OptionGroupSingleton<AdamOptions>.Instance.SmokeCooldown;
    public override LoadableAsset<Sprite>? Sprite => null;

    protected override bool IsButtonActive()
    {
        return Role != null && !Role.SmokeActive;
    }

    protected override void OnClick()
    {
        var pos = PlayerControl.LocalPlayer.transform.position;
        AdamRpc.RpcActivateSmoke(
            PlayerControl.LocalPlayer,
            pos.x,
            pos.y,
            OptionGroupSingleton<AdamOptions>.Instance.SmokeDuration
        );
    }
}
