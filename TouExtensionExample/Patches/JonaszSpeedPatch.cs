using HarmonyLib;
using MiraAPI.GameOptions;
using TouExtensionExample.Options.Roles.Crewmate;
using TouExtensionExample.Roles.Crewmate;
using UnityEngine;

namespace TouExtensionExample.Patches;

[HarmonyPatch(typeof(PlayerPhysics), nameof(PlayerPhysics.FixedUpdate))]
public static class JonaszSpeedPatch
{
    public static void Postfix(PlayerPhysics __instance)
    {
        if (__instance.myPlayer == null || __instance.myPlayer.Data?.Role is not JonaszRole jonasz)
        {
            return;
        }

        if (!__instance.myPlayer.AmOwner || __instance.myPlayer.Data.IsDead)
        {
            return;
        }

        if (jonasz.IsDashing)
        {
            __instance.body.velocity *= OptionGroupSingleton<JonaszOptions>.Instance.DashSpeed;
            jonasz.DashTimer -= Time.fixedDeltaTime;

            if (jonasz.DashTimer <= 0)
            {
                jonasz.IsDashing = false;
            }
        }
        else
        {
            __instance.body.velocity *= OptionGroupSingleton<JonaszOptions>.Instance.SpeedMultiplier;
        }
    }
}
