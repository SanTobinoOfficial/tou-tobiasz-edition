using Reactor.Networking.Attributes;
using TouExtensionExample.Roles.Neutral;
using UnityEngine;
using Object = UnityEngine.Object;

namespace TouExtensionExample.Modules;

public static class EmilRpc
{
    [MethodRpc(200)]
    public static void RpcEatBody(PlayerControl player, byte bodyPlayerId)
    {
        foreach (var body in Object.FindObjectsOfType<DeadBody>())
        {
            if (body.ParentId == bodyPlayerId)
            {
                Object.Destroy(body.gameObject);
                break;
            }
        }

        if (player.Data.Role is EmilRole emil)
        {
            emil.EatenPlayers.Add(bodyPlayerId);
        }
    }
}
