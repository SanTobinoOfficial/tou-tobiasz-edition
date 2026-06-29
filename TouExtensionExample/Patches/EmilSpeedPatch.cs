using HarmonyLib;
using MiraAPI.GameOptions;
using TouExtensionExample.Options.Roles.Neutral;
using TouExtensionExample.Roles.Neutral;
using TownOfUs.Extensions;

namespace TouExtensionExample.Patches;

[HarmonyPatch(typeof(PlayerPhysics), nameof(PlayerPhysics.FixedUpdate))]
public static class EmilSpeedPatch
{
    public static void Postfix(PlayerPhysics __instance)
    {
        if (__instance.myPlayer == null || __instance.myPlayer.Data?.Role is not EmilRole)
        {
            return;
        }

        if (!__instance.myPlayer.AmOwner || __instance.myPlayer.Data.IsDead)
        {
            return;
        }

        var multiplier = OptionGroupSingleton<EmilOptions>.Instance.SpeedMultiplier;
        if (multiplier < 1f)
        {
            __instance.body.velocity *= multiplier;
        }
    }
}
