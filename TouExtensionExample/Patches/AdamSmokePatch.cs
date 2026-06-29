using HarmonyLib;
using MiraAPI.GameOptions;
using TouExtensionExample.Options.Roles.Impostor;
using TouExtensionExample.Roles.Impostor;
using UnityEngine;

namespace TouExtensionExample.Patches;

// Ticks down smoke timer on Adam's side and deactivates when expired.
[HarmonyPatch(typeof(PlayerPhysics), nameof(PlayerPhysics.FixedUpdate))]
public static class AdamSmokeTimerPatch
{
    public static void Postfix(PlayerPhysics __instance)
    {
        if (__instance.myPlayer?.Data?.Role is not AdamRole adam) return;
        if (!adam.SmokeActive) return;

        adam.SmokeTimer -= Time.fixedDeltaTime;
        if (adam.SmokeTimer <= 0f)
        {
            adam.SmokeActive = false;
            adam.SmokeTimer = 0f;
        }
    }
}

// Reduces vision for crewmates caught inside Adam's smoke cloud.
[HarmonyPatch(typeof(ShipStatus), nameof(ShipStatus.CalculateLightRadius))]
public static class AdamVisionPatch
{
    public static void Postfix(ref float __result, GameData.PlayerInfo player)
    {
        if (player == null || player.IsDead) return;
        // Impostors see through the smoke.
        if (player.Role != null && player.Role.IsImpostor) return;

        var smokeRadius = OptionGroupSingleton<AdamOptions>.Instance.SmokeRadius;
        var visionMult = OptionGroupSingleton<AdamOptions>.Instance.VisionMultiplier;

        var targetPc = player.Object;
        if (targetPc == null) return;

        var targetPos = (Vector2)targetPc.transform.position;

        foreach (var pc in PlayerControl.AllPlayerControls)
        {
            if (pc.Data?.Role is not AdamRole adam || !adam.SmokeActive) continue;

            var dist = Vector2.Distance(new Vector2(adam.SmokeX, adam.SmokeY), targetPos);
            if (dist <= smokeRadius)
            {
                __result *= visionMult;
                return;
            }
        }
    }
}
