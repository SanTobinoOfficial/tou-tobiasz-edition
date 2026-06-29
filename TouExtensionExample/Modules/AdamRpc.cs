using Reactor.Networking.Attributes;
using TouExtensionExample.Roles.Impostor;

namespace TouExtensionExample.Modules;

public static class AdamRpc
{
    [MethodRpc(201)]
    public static void RpcActivateSmoke(PlayerControl player, float x, float y, float duration)
    {
        if (player.Data.Role is not AdamRole adam) return;
        adam.SmokeActive = true;
        adam.SmokeX = x;
        adam.SmokeY = y;
        adam.SmokeTimer = duration;
    }
}
