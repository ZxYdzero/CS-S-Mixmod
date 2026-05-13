/**
 * API模块
 * 
 * 本模块提供API接口，允许其他插件访问Mixmod的功能和数据。
 */

#if defined _mixmod_api_included
  #endinput
#endif
#define _mixmod_api_included

// API版本
#define MIXMOD_API_VERSION 1

// API句柄
Handle g_hForward_OnMixStart = INVALID_HANDLE;
Handle g_hForward_OnMixEnd = INVALID_HANDLE;
Handle g_hForward_OnHalfTime = INVALID_HANDLE;
Handle g_hForward_OnRoundStart = INVALID_HANDLE;
Handle g_hForward_OnRoundEnd = INVALID_HANDLE;
Handle g_hForward_OnPlayerReady = INVALID_HANDLE;
Handle g_hForward_OnPlayerNotReady = INVALID_HANDLE;

/**
 * 注册 API Native 和库。
 *
 * SourceMod 要求动态 Native 尽早注册；这里由 AskPluginLoad2 调用，
 * 避免其他插件加载时看不到本插件提供的 natives。
 */
void Mix_RegisterAPI()
{
    CreateNative("MixMod_GetAPIVersion", Native_GetAPIVersion);
    CreateNative("MixMod_IsMatchLive", Native_IsMatchLive);
    CreateNative("MixMod_GetCurrentRound", Native_GetCurrentRound);
    CreateNative("MixMod_GetCurrentHalf", Native_GetCurrentHalf);
    CreateNative("MixMod_GetTeamScore", Native_GetTeamScore);
    CreateNative("MixMod_GetPlayerStats", Native_GetPlayerStats);
    CreateNative("MixMod_IsPlayerReady", Native_IsPlayerReady);
    CreateNative("MixMod_GetReadyCount", Native_GetReadyCount);
    CreateNative("MixMod_GetCurrentMap", Native_GetCurrentMap);
    CreateNative("MixMod_GetTeamName", Native_GetTeamName);
    
    // 注册API库
    RegPluginLibrary("mixmod");
}

/**
 * 初始化API Forward。
 */
void Mix_InitAPI()
{
    // 创建全局Forward
    g_hForward_OnMixStart = CreateGlobalForward("MixMod_OnMixStart", ET_Ignore);
    g_hForward_OnMixEnd = CreateGlobalForward("MixMod_OnMixEnd", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
    g_hForward_OnHalfTime = CreateGlobalForward("MixMod_OnHalfTime", ET_Ignore, Param_Cell, Param_Cell);
    g_hForward_OnRoundStart = CreateGlobalForward("MixMod_OnRoundStart", ET_Ignore, Param_Cell, Param_Cell);
    g_hForward_OnRoundEnd = CreateGlobalForward("MixMod_OnRoundEnd", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
    g_hForward_OnPlayerReady = CreateGlobalForward("MixMod_OnPlayerReady", ET_Ignore, Param_Cell);
    g_hForward_OnPlayerNotReady = CreateGlobalForward("MixMod_OnPlayerNotReady", ET_Ignore, Param_Cell);
}

/**
 * 调用比赛开始事件
 */
void Mix_API_OnMixStart()
{
    Call_StartForward(g_hForward_OnMixStart);
    Call_Finish();
}

/**
 * 调用比赛结束事件
 * 
 * @param winner 获胜队伍 (1=平局, 2=T, 3=CT)
 * @param ct_score CT队伍得分
 * @param t_score T队伍得分
 */
void Mix_API_OnMixEnd(int winner, int ct_score, int t_score)
{
    Call_StartForward(g_hForward_OnMixEnd);
    Call_PushCell(winner);
    Call_PushCell(ct_score);
    Call_PushCell(t_score);
    Call_Finish();
}

/**
 * 调用半场事件
 * 
 * @param ct_score CT队伍得分
 * @param t_score T队伍得分
 */
void Mix_API_OnHalfTime(int ct_score, int t_score)
{
    Call_StartForward(g_hForward_OnHalfTime);
    Call_PushCell(ct_score);
    Call_PushCell(t_score);
    Call_Finish();
}

/**
 * 调用回合开始事件
 * 
 * @param round 当前回合
 * @param half 当前半场
 */
void Mix_API_OnRoundStart(int round, int half)
{
    Call_StartForward(g_hForward_OnRoundStart);
    Call_PushCell(round);
    Call_PushCell(half);
    Call_Finish();
}

/**
 * 调用回合结束事件
 * 
 * @param winner 获胜队伍 (2=T, 3=CT)
 * @param ct_score CT队伍得分
 * @param t_score T队伍得分
 */
void Mix_API_OnRoundEnd(int winner, int ct_score, int t_score)
{
    Call_StartForward(g_hForward_OnRoundEnd);
    Call_PushCell(winner);
    Call_PushCell(ct_score);
    Call_PushCell(t_score);
    Call_Finish();
}

/**
 * 调用玩家准备事件
 * 
 * @param client 客户端ID
 */
void Mix_API_OnPlayerReady(int client)
{
    Call_StartForward(g_hForward_OnPlayerReady);
    Call_PushCell(client);
    Call_Finish();
}

/**
 * 调用玩家取消准备事件
 * 
 * @param client 客户端ID
 */
void Mix_API_OnPlayerNotReady(int client)
{
    Call_StartForward(g_hForward_OnPlayerNotReady);
    Call_PushCell(client);
    Call_Finish();
}

// =============================================================================
// Native函数
// =============================================================================

/**
 * 获取API版本
 */
public int Native_GetAPIVersion(Handle plugin, int numParams)
{
    return MIXMOD_API_VERSION;
}

/**
 * 检查比赛是否正在进行
 */
public int Native_IsMatchLive(Handle plugin, int numParams)
{
    return g_bHasMixStarted && g_bDidLiveStarted;
}

/**
 * 获取当前回合
 */
public int Native_GetCurrentRound(Handle plugin, int numParams)
{
    return g_iCurrentRound;
}

/**
 * 获取当前半场
 */
public int Native_GetCurrentHalf(Handle plugin, int numParams)
{
    return g_iCurrentHalf;
}

/**
 * 获取队伍得分
 */
public int Native_GetTeamScore(Handle plugin, int numParams)
{
    int team = GetNativeCell(1);
    
    if (team == 2) { // T
        return g_iTScore;
    } else if (team == 3) { // CT
        return g_iCTScore;
    }
    
    return 0;
}

/**
 * 获取玩家统计数据
 */
public int Native_GetPlayerStats(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) {
        return false;
    }
    
    // 获取统计数据结构
    Handle hStats = GetNativeCell(2);
    
    // 设置统计数据
    SetTrieValue(hStats, "kills", g_PlayerStats[client].kills);
    SetTrieValue(hStats, "deaths", g_PlayerStats[client].deaths);
    SetTrieValue(hStats, "assists", g_PlayerStats[client].assists);
    SetTrieValue(hStats, "headshots", g_PlayerStats[client].headshots);
    SetTrieValue(hStats, "damage", g_PlayerStats[client].damage);
    SetTrieValue(hStats, "clutches", g_PlayerStats[client].clutches);
    SetTrieValue(hStats, "clutch_wins", g_PlayerStats[client].clutches);
    SetTrieValue(hStats, "clutch_losses", g_PlayerStats[client].clutch_losses);
    SetTrieValue(hStats, "rounds_played", g_PlayerStats[client].rounds_played);
    SetTrieValue(hStats, "shots_fired", g_PlayerStats[client].shots_fired);
    SetTrieValue(hStats, "shots_hit", g_PlayerStats[client].shots_hit);
    SetTrieValue(hStats, "bomb_plants", g_PlayerStats[client].bomb_plants);
    SetTrieValue(hStats, "bomb_defuses", g_PlayerStats[client].bomb_defuses);
    
    // 计算的统计数据
    float kd = g_PlayerStats[client].GetKDRatio();
    float hs_percent = g_PlayerStats[client].GetHeadshotPercentage();
    float adr = g_PlayerStats[client].GetADR();
    float accuracy = g_PlayerStats[client].GetAccuracy();
    
    SetTrieValue(hStats, "kd_ratio", kd);
    SetTrieValue(hStats, "headshot_percent", hs_percent);
    SetTrieValue(hStats, "adr", adr);
    SetTrieValue(hStats, "accuracy", accuracy);
    
    return true;
}

/**
 * 检查玩家是否准备
 */
public int Native_IsPlayerReady(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    
    if (client < 1 || client > MaxClients) {
        return false;
    }
    
    return g_bReadyPlayers[client];
}

/**
 * 获取准备玩家数量
 */
public int Native_GetReadyCount(Handle plugin, int numParams)
{
    return g_iReadyCount;
}

/**
 * 获取当前地图
 */
public int Native_GetCurrentMap(Handle plugin, int numParams)
{
    int maxlen = GetNativeCell(2);
    char[] buffer = new char[maxlen];
    
    strcopy(buffer, maxlen, g_szMatchMap);
    
    SetNativeString(1, buffer, maxlen);
    return true;
}

/**
 * 获取队伍名称
 */
public int Native_GetTeamName(Handle plugin, int numParams)
{
    int team = GetNativeCell(1);
    int maxlen = GetNativeCell(3);
    char[] buffer = new char[maxlen];
    
    if (team == 2) { // T
        GetConVarString(g_hCvarCusomNameTeamT, buffer, maxlen);
    } else if (team == 3) { // CT
        GetConVarString(g_hCvarCusomNameTeamCT, buffer, maxlen);
    } else {
        strcopy(buffer, maxlen, "Unknown");
    }
    
    SetNativeString(2, buffer, maxlen);
    return true;
}
