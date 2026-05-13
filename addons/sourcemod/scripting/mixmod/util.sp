/**
 * 辅助功能模块
 */

#if defined _mixmod_util_included
  #endinput
#endif
#define _mixmod_util_included

/**
 * 检查是否为可直接发送菜单/聊天的游戏内客户端。
 */
bool Mix_IsInGameClient(int client)
{
    return (client >= 1 && client <= MaxClients && IsClientInGame(client));
}

/**
 * 获取命令来源名称。client=0 或无效客户端会显示为服务器，避免自动流程
 * 调用 GetClientName(0) 触发运行时错误。
 */
void Mix_GetCommandSourceName(int client, char[] buffer, int maxlength)
{
    if (Mix_IsInGameClient(client)) {
        GetClientName(client, buffer, maxlength);
    } else {
        strcopy(buffer, maxlength, "服务器");
    }
}

/**
 * 向队伍中的所有玩家显示菜单
 * 
 * @param menu     要显示的菜单句柄
 * @param team     目标队伍
 * @param time     显示时间
 * @return         true如果至少有一名玩家收到菜单，否则false
 */
bool VoteMenuToTeam(Handle menu, int team, int time)
{
    int total = 0;
    int[] players = new int[MaxClients];
    
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != team) {
            continue;
        }
        
        players[total++] = i;
    }
    
    if (total > 0) {
        return VoteMenu(menu, players, total, time);
    }
    
    return false;
}

/**
 * 对整个服务器进行投票
 * 
 * @param menu 菜单句柄
 * @param time 显示时间
 * @param flags 菜单标志
 */
void Mix_VoteMenuToAll(Handle menu, int time, int flags = 0)
{
    int total = 0;
    int[] players = new int[MaxClients];
    
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i)) {
            continue;
        }
        
        players[total++] = i;
    }
    
    if (total > 0) {
        VoteMenu(menu, players, total, time, flags);
    }
}
