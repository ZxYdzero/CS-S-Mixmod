/**
 * 辅助功能模块
 */

#if defined _mixmod_util_included
  #endinput
#endif
#define _mixmod_util_included

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

/**
 * 获取菜单属性
 */
bool GetMenuProp(Handle menu, const char[] prop, any &value)
{
    Handle hProp;
    
    return (GetTrieValue(view_as<StringMap>(menu), prop, hProp) && (value = hProp) != INVALID_HANDLE);
}

/**
 * 设置菜单属性
 */
void SetMenuProp(Handle menu, const char[] prop, any value)
{
    SetTrieValue(view_as<StringMap>(menu), prop, value);
}