using MiraAPI.GameOptions;
using MiraAPI.Hud;
using MiraAPI.Keybinds;
using MiraAPI.Utilities.Assets;
using Reactor.Utilities;
using TouExtensionExample.Assets;
using TouExtensionExample.Modules;
using TouExtensionExample.Options.Roles.Neutral;
using TouExtensionExample.Roles.Neutral;
using TownOfUs.Buttons;
using UnityEngine;
using Object = UnityEngine.Object;

namespace TouExtensionExample.Buttons.Neutral;

public sealed class EmilEatButton : TownOfUsRoleButton<EmilRole>
{
    public override string Name => "Eat";
    public override BaseKeybind Keybind => Keybinds.SecondaryAction;
    public override Color TextOutlineColor => TouExampleColors.Emil;
    public override float Cooldown => OptionGroupSingleton<EmilOptions>.Instance.EatCooldown;
    public override LoadableAsset<Sprite> Sprite => ExampleNeutAssets.SentinelExplodeSprite;

    private DeadBody? _closestBody;

    public override bool CanUse()
    {
        _closestBody = GetClosestBody();
        return base.CanUse() && _closestBody != null;
    }

    protected override void OnClick()
    {
        if (_closestBody == null)
        {
            return;
        }

        EmilRpc.RpcEatBody(PlayerControl.LocalPlayer, _closestBody.ParentId);
        CustomButtonSingleton<EmilKillButton>.Instance.ResetCooldownAndOrEffect();
    }

    private DeadBody? GetClosestBody()
    {
        var bodies = Object.FindObjectsOfType<DeadBody>();
        if (bodies == null || bodies.Count == 0)
        {
            return null;
        }

        var myPos = PlayerControl.LocalPlayer.GetTruePosition();
        var eatRange = OptionGroupSingleton<EmilOptions>.Instance.EatRange;
        DeadBody? closest = null;
        var closestDist = float.MaxValue;

        foreach (var body in bodies)
        {
            var dist = Vector2.Distance(myPos, body.TruePosition);
            if (dist <= eatRange && dist < closestDist)
            {
                closestDist = dist;
                closest = body;
            }
        }

        return closest;
    }
}
