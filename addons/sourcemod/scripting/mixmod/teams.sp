/**
 * 团队管理模块
 */

#if defined _mixmod_teams_included
  #endinput
#endif
#define _mixmod_teams_included

// 确保CS团队常量定义正确
#if !defined CS_TEAM_T
#define CS_TEAM_T 2
#endif

#if !defined CS_TEAM_CT
#define CS_TEAM_CT 3
#endif

#if !defined CS_TEAM_SPECTATOR
#define CS_TEAM_SPECTATOR 1
#endif

// =============================================================================
// CT和T模型
// =============================================================================
static const String:g_szCTModels[4][] = 
{
    "models/player/ct_urban.mdl",
    "models/player/ct_gsg9.mdl",
    "models/player/ct_sas.mdl",
    "models/player/ct_gign.mdl"
};

static const String:g_szTModels[4][] = 
{
    "models/player/t_phoenix.mdl",
    "models/player/t_leet.mdl",
    "models/player/t_arctic.mdl",
    "models/player/t_guerilla.mdl"
};

/**
 * 交换队伍
 */
void Mix_SwapTeams()
{
    bool flag = false;
    if (g_bDidLiveStarted) {
        g_bDidLiveStarted = false;
        flag = true;
    }

    int team;
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i))
            continue;

        team = GetClientTeam(i);
        if (team == TEAM_T) {
            ChangeClientTeam(i, TEAM_CT);
            PrintToChat(i, "\x04[%s]:\x03 你已被调换至 \x01防守方\x03 队伍", MODNAME);
        } else if (team == TEAM_CT) {
            ChangeClientTeam(i, TEAM_T);
            PrintToChat(i, "\x04[%s]:\x03 你已被调换至 \x01进攻方\x03 队伍", MODNAME);
        }
    }
    PrintToChatAll("\x04[%s]:\x03 所有玩家已交换队伍", MODNAME);
    
    if (flag) {
        g_bDidLiveStarted = true;
    }
}

/**
 * 半场结束时交换队伍的定时器回调
 */
public Action Mix_SwapTimer(Handle timer)
{
    g_bDidLiveStarted = false; // 在交换队伍前禁用Live状态
    
    int team;
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client) && !IsFakeClient(client) && IsClientConnected(client)) {
            team = GetClientTeam(client);
            
            if (team == CS_TEAM_CT) {
                CS_SwitchTeam(client, CS_TEAM_T);
                if (IsPlayerAlive(client)) {
                    SetEntityModel(client, g_szTModels[GetRandomInt(0, 3)]);
                }
            } else if (team == CS_TEAM_T) {
                CS_SwitchTeam(client, CS_TEAM_CT);
                if (IsPlayerAlive(client)) {
                    SetEntityModel(client, g_szCTModels[GetRandomInt(0, 3)]);
                }
            }
        }
    }
    
    if (GetConVarInt(g_hCvarHalfAutoLiveStart) == 1) {
        g_bDidLiveStarted = true;
    }

    return Plugin_Continue;
}

/**
 * 移除玩家的枪械
 * 
 * @param client 目标客户端
 */
void Mix_RemovePlayerGuns(int client)
{
    int gunEnt;
    for (int i = 0; i < 5; i++) {
        if (i == 2) // 不移除刀
            continue; 
            
        while ((gunEnt = GetPlayerWeaponSlot(client, i)) != -1) {
            RemovePlayerItem(client, gunEnt);
        }
    }
    // 切换到刀 - 当我重新给予武器时，它们会自动切换
    ClientCommand(client, "slot3");
}

/**
 * 随机分配CT队员
 */
void Mix_RandomizeCTPlayers()
{
    int numSwitched = 0;
    while (numSwitched < 5) {
        int client = Mix_GetRandomPlayer(TEAM_T);
        
        if (client != -1) {
            Mix_SwitchPlayerTeam(client, CS_TEAM_CT);
        
            if (IsPlayerAlive(client)) {
                CS_RespawnPlayer(client);
            }
            
            numSwitched++;
        } else {
            LogMessage("随机分配CT队员时出错...");
            PrintToChatAll("\x04[%s]:\x01 错误: 无法从T队伍中获取随机玩家!", MODNAME);
            break;
        }
    }
}

/**
 * 切换玩家队伍并设置相应的模型
 * 
 * @param client 目标客户端索引
 * @param team   目标队伍
 */
void Mix_SwitchPlayerTeam(int client, int team)
{
    if (team > CS_TEAM_SPECTATOR) {
        CS_SwitchTeam(client, team);
        Mix_SetRandomModel(client, team);
    } else {
        ChangeClientTeam(client, team);
    }
}

/**
 * 设置随机模型
 * 
 * @param client 目标客户端索引
 * @param team   目标队伍
 */
void Mix_SetRandomModel(int client, int team)
{
    int random = GetRandomInt(0, 3);
    
    switch (team) {
        case CS_TEAM_T:
            SetEntityModel(client, g_szTModels[random]);
        case CS_TEAM_CT:
            SetEntityModel(client, g_szCTModels[random]);
    }
}

/**
 * 获取指定队伍中的随机玩家
 * 
 * @param team 目标队伍
 * @return     随机玩家索引，如果没有找到则返回-1
 */
int Mix_GetRandomPlayer(int team)
{
    int[] players = new int[MaxClients+1];
    int playerCount = 0;
    
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team) {
            players[playerCount++] = i;
        }
    }
    
    if (playerCount == 0) {
        return -1;
    } else {
        return players[GetRandomInt(0, playerCount-1)];
    }
}

/**
 * 禁用购买区
 * 
 * @return 操作是否成功
 */
bool Mix_DisableBuyZone()
{
    int ent = -1;
    bool disabled = false;
    
    while ((ent = FindEntityByClassname(ent, "func_buyzone")) != -1) {
        AcceptEntityInput(ent, "Disable");
        disabled = true;
    }
    
    return disabled;
}

/**
 * 启用购买区
 * 
 * @return 操作是否成功
 */
bool Mix_EnableBuyZone()
{
    int ent = -1;
    bool enabled = false;
    
    while ((ent = FindEntityByClassname(ent, "func_buyzone")) != -1) {
        AcceptEntityInput(ent, "Enable");
        enabled = true;
    }
    
    return enabled;
}

/**
 * 踢出指定队伍的玩家
 * 
 * @param client         执行命令的管理员
 * @param team           要踢出的队伍
 * @param adminsImmunity 是否踢出管理员
 */
void Mix_KickTeam(int client, int team, int adminsImmunity)
{
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i) && (client != i) && (GetClientTeam(i) == team)) {
            if (adminsImmunity == 1) {
                if (GetUserAdmin(i) == INVALID_ADMIN_ID) {
                    KickClient(i, "[%s]: 你已被管理员踢出服务器!", MODNAME);
                }
            } else {
                KickClient(i, "[%s]: 你已被管理员踢出服务器!", MODNAME);
            }
        }
    }
}

/**
 * 处理刀局结束后的队伍选择投票
 */
public int Mix_HandleTeamsVoteMenu(Handle menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End) {
        CloseHandle(menu);
    } else if (action == MenuAction_VoteEnd) {
        if (param1 == 0) {  // 投票选择"是"
            int team;
            for (int i = 1; i <= MaxClients; i++) {
                if (IsClientInGame(i)) {
                    team = GetClientTeam(i);
                    if (team == TEAM_T) {
                        CS_SwitchTeam(i, TEAM_CT);
                    } else if (team == TEAM_CT) {
                        CS_SwitchTeam(i, TEAM_T);
                    }
                }
            }
        }
        g_bIsKo3Running = false;
        PrintToChatAll("\x04[%s]:\x03 队伍已选择!", MODNAME);
        Mix_ExecuteMr12Config(0);
    }
    return 0;
}

/**
 * 随机分配队伍
 */
void Mix_RandomizeTeams()
{
    // 将所有人移至T队伍
    for(int i = 1; i <= MaxClients; i++) {
        if(IsClientInGame(i) && !IsFakeClient(i)) {
            Mix_SwitchPlayerTeam(i, CS_TEAM_T);
        }
    }
    
    // 随机选择5名T玩家并移至CT队伍
    Mix_RandomizeCTPlayers();
    PrintToChatAll("\x04[%s]:\x03 队伍已随机分配!", MODNAME);
}

/**
 * 将玩家移至观察者队伍
 * 
 * @param client       执行命令的客户端
 * @param targetClient 目标客户端
 */
void Mix_MoveToSpectator(int client, int targetClient)
{
    ChangeClientTeam(targetClient, TEAM_SPEC);
    
    char targetName[MAX_NAME_LENGTH];
    GetClientName(targetClient, targetName, sizeof(targetName));
    
    PrintToChat(targetClient, "\x04[%s]:\x03 你已被移至观察者队伍!", MODNAME);
    PrintToChat(client, "\x04[%s]:\x03 %s 已被移至观察者队伍!", MODNAME, targetName);
} 