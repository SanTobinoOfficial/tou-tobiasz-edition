using MiraAPI.GameOptions;
using MiraAPI.Hud;
using MiraAPI.Keybinds;
using MiraAPI.Utilities.Assets;
using Reactor.Utilities;
using TouExtensionExample.Assets;
using TouExtensionExample.Options.Roles.Crewmate;
using TouExtensionExample.Roles.Crewmate;
using TownOfUs.Buttons;
using TownOfUs.Utilities;
using UnityEngine;

namespace TouExtensionExample.Buttons.Crewmate;

public sealed class JonaszBirdButton : TownOfUsRoleButton<JonaszRole>
{
    public override string Name => "Bird";
    public override BaseKeybind Keybind => Keybinds.SecondaryAction;
    public override Color TextOutlineColor => TouExampleColors.Jonasz;
    public override float Cooldown => OptionGroupSingleton<JonaszOptions>.Instance.BirdCooldown;
    public override LoadableAsset<Sprite> Sprite => ExampleNeutAssets.SentinelExplodeSprite;

    protected override void OnClick()
    {
        var target = PlayerControl.LocalPlayer.GetClosestLivingPlayer(true,
            OptionGroupSingleton<JonaszOptions>.Instance.BirdRange);

        if (target == null)
        {
            return;
        }

        var isEvil = target.Data.Role.IsImpostor;
        var color = isEvil ? Color.red : Color.green;
        target.cosmetics.SetOutline(true, new Il2CppSystem.Nullable<Color>(color));

        Coroutines.Start(CoRemoveOutline(target,
            OptionGroupSingleton<JonaszOptions>.Instance.BirdRevealDuration));
    }

    private static System.Collections.IEnumerator CoRemoveOutline(PlayerControl target, float delay)
    {
        yield return new WaitForSeconds(delay);
        if (target != null)
        {
            target.cosmetics.SetOutline(false, new Il2CppSystem.Nullable<Color>(Color.clear));
        }
    }
}
