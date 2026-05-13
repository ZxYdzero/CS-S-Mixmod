/**
 * 全局变量模块
 *
 * 本模块包含插件使用的所有全局变量，按功能分类组织以便于维护和更新。
 * 所有变量都使用匈牙利命名法，前缀表示变量类型：
 * - g_i: 整数
 * - g_b: 布尔值
 * - g_h: 句柄
 * - g_sz: 字符串
 */

#if defined _mixmod_globals_included
  #endinput
#endif
#define _mixmod_globals_included

// =============================================================================
// 回合和比分计数相关变量
// =============================================================================
int g_iCurrentRound = 1;        // 当前回合数
int g_iCurrentHalf = 1;         // 当前半场（1或2）
int g_iCTScore = 0;             // CT队伍当前半场得分
int g_iTScore = 0;              // T队伍当前半场得分
int g_iCTScore2 = 0;            // CT队伍第二半场得分
int g_iTScore2 = 0;             // T队伍第二半场得分
int g_iCTScoreH1 = 0;           // CT队伍第一半场得分（用于记录）
int g_iTScoreH1 = 0;            // T队伍第一半场得分（用于记录）

// =============================================================================
// 插件状态相关变量
// =============================================================================
bool s_bMixStartCalled = false;

bool g_bHasMixStarted = false;      // 是否已开始比赛
bool g_bDidLiveStarted = false;     // 是否已开始Live
bool g_bSwapNow = false;            // 是否需要立即交换队伍
bool g_bIsKo3Running = false;       // 是否正在进行刀局
// 以下变量在某些模块中可能未使用，但保留以便将来扩展
#pragma unused g_bIsRandomPasswordWasLastPw
bool g_bIsRandomPasswordWasLastPw = false; // 上次是否使用了随机密码
bool g_bIsBuyZoneDisabled = false;  // 购买区是否被禁用
#pragma unused g_bIsRandomBeingUsed
bool g_bIsRandomBeingUsed = false;  // 是否正在使用随机功能

// =============================================================================
// 插件调试和功能选项
// =============================================================================
// 尚无作用
// bool g_bEnablePluginChecking = false;

// =============================================================================
// 地图列表相关变量
// =============================================================================
bool g_bIsMapListGenerated = false;
Handle g_hMapListMenu = INVALID_HANDLE;

// =============================================================================
// 满十菜单相关变量
// =============================================================================
bool g_bIsMixMenuGenerated = false;
Handle g_hMixMenu = INVALID_HANDLE;
Handle g_hAdminMenu = INVALID_HANDLE;

// =============================================================================
// 面板相关变量
// =============================================================================
Handle g_hWinTeamPanel = INVALID_HANDLE;
Handle g_hHelpPanel = INVALID_HANDLE;

// =============================================================================
// 插件ConVar句柄
// =============================================================================
Handle g_hCvarEnabled = INVALID_HANDLE;
Handle g_hCvarShowMoneyAndWeapons = INVALID_HANDLE;
Handle g_hCvarShowScores = INVALID_HANDLE;
Handle g_hCvarEnableRRCommand = INVALID_HANDLE;
Handle g_hCvarPlayTeamSwapedSound = INVALID_HANDLE;
Handle g_hCvarCusomNameTeamCT = INVALID_HANDLE;
Handle g_hCvarCusomNameTeamT = INVALID_HANDLE;
Handle g_hCvarRestartTimeInLiveCommand = INVALID_HANDLE;
Handle g_hCvarUseZBMatchCommand = INVALID_HANDLE;
Handle g_hCvarMr3Enabled = INVALID_HANDLE;
Handle g_hCvarStopCustomCfg = INVALID_HANDLE;
Handle g_hCvarShowSwitchInPanel = INVALID_HANDLE;
Handle g_hCvarShowCashInPanel = INVALID_HANDLE;
Handle g_hCvarHalfAutoLiveStart = INVALID_HANDLE;
Handle g_hCvarCustomLiveCfg = INVALID_HANDLE;
Handle g_hCvarCustomPracCfg = INVALID_HANDLE;
Handle g_hCvarCustomMr3Cfg = INVALID_HANDLE;
Handle g_hCvarKickAdmins = INVALID_HANDLE;
#pragma unused g_hCvarDisableSayCommand
Handle g_hCvarDisableSayCommand = INVALID_HANDLE; // 禁用聊天命令的ConVar
Handle g_hCvarEnableKnifeRound = INVALID_HANDLE;
Handle g_hCvarUseKo3Command = INVALID_HANDLE;
Handle g_hCvarInformWinnerInPanel = INVALID_HANDLE;
Handle g_hCvarRpwShowPass = INVALID_HANDLE;
Handle g_hCvarRemoveProps = INVALID_HANDLE;
Handle g_hCvarAutoMixEnabled = INVALID_HANDLE;
Handle g_hCvarAutoMixRandomize = INVALID_HANDLE;
Handle g_hCvarEnableAutoSourceTVRecord = INVALID_HANDLE;
Handle g_hCvarAutoSourceTVRecordSaveDir = INVALID_HANDLE;
Handle g_hCvarKnifeWinTeamVote = INVALID_HANDLE;
Handle g_hCvarEnablePasswords = INVALID_HANDLE;
#pragma unused g_hCvarAllowManualSwitching
Handle g_hCvarAllowManualSwitching = INVALID_HANDLE; // 允许手动切换队伍的ConVar
Handle g_hCvarDelayBeforeSwapping = INVALID_HANDLE;
Handle g_hCvarShowTkMessage = INVALID_HANDLE;
Handle g_hCvarRemovePassWhenMixIsEnded = INVALID_HANDLE;
Handle g_hCvarShowMVP = INVALID_HANDLE;
Handle g_hCvarDontRemovePropsMaps = INVALID_HANDLE;
Handle g_hCvarEnableVoiceCommands = INVALID_HANDLE;
Handle g_hPluginVersion = INVALID_HANDLE;
Handle g_hFogDelete = INVALID_HANDLE;
Handle g_hCvarOpenAutoKick = INVALID_HANDLE; // 允许在凑满十个人自动踢人

// =============================================================================
// 游戏ConVar及偏移量
// =============================================================================
Handle g_hRestartGame = INVALID_HANDLE;
Handle g_hPassword = INVALID_HANDLE;
Handle g_hFreezeTime = INVALID_HANDLE;
Handle g_hHostName = INVALID_HANDLE;
int g_iAccount = -1;

// =============================================================================
// 自动战局设置
// =============================================================================
int g_iReadyCount = 0;
bool g_bReadyPlayers[MAXPLAYERS+1] = {false, ...};
int g_iReadyPlayersData[MAXPLAYERS+1] = {-1, ...};
bool g_bAllowReady = true;
bool g_bIsItManual = true;
char g_szHostName[150];
Handle g_hReadyStatus = INVALID_HANDLE;

// =============================================================================
// 自动录制相关
// =============================================================================
bool g_bIsRecording = false;     // 是否正在录制
#pragma unused g_bIsRecordManual
bool g_bIsRecordManual = false;  // 是否是手动开始的录制

// =============================================================================
// 客户端分数保存（重新开始时）
// =============================================================================
bool g_bSaveClientsScore = false;

// =============================================================================
// MVP系统
// =============================================================================
int g_iScoresOfTheRound[MAXPLAYERS+1] = {0, ...};
int g_iScoresOfTheGame[MAXPLAYERS+1] = {0, ...};
int g_iDeathsOfTheGame[MAXPLAYERS+1] = {0, ...};

// =============================================================================
// 静音或禁言系统
// =============================================================================
bool g_bMutedPlayers[MAXPLAYERS+1] = {false, ...};
bool g_bGaggedPlayers[MAXPLAYERS+1] = {false, ...};

// =============================================================================
// 地图属性标记
// =============================================================================
bool g_bIsMapValidToRemoveProps = true;

// =============================================================================
// 10人准备后的选图相关
// =============================================================================
bool g_bHasVoteMap = false;
char g_szMapNames[MAX_MAPS][32];
char g_szMatchMap[32] = "";
bool g_bTenVoted = false;

// =============================================================================
// 10人准备计时器相关
// =============================================================================
int g_iSecond = 30;
bool g_bIsKicked = false;
bool g_bKickCountdownActive = false;

// =============================================================================
// HUD相关
// =============================================================================
Handle g_hHudTimer = INVALID_HANDLE;
Handle g_hKickUnreadyTimer = INVALID_HANDLE;
bool g_bHidePanel[MAXPLAYERS+1] = {false, ...};

// =============================================================================
// 统计口径相关
// =============================================================================
int g_iLastKnownHealth[MAXPLAYERS+1] = {0, ...}; // 用于按实际剩余 HP 结算有效伤害/ADR
bool g_bClutchActive = false;                    // 当前回合是否已有残局待结算
int g_iClutchPlayer = 0;                         // 当前残局玩家
int g_iClutchUserId = 0;                         // 当前残局玩家userid，用于防止断线后slot复用
int g_iClutchTeam = 0;                           // 当前残局玩家队伍
int g_iClutchEnemyCount = 0;                     // 进入残局时面对的敌人数

/**
 * 重置比赛参数和玩家状态
 *
 * 此函数用于重置所有与比赛相关的状态变量，通常在比赛结束或需要重新开始时调用。
 * 它会重置比分、回合计数、玩家状态等所有相关变量。
 */
void Mix_ResetMatchState()
{
    // 在比赛结束时显示统计数据
    if (g_bHasMixStarted && g_bDidLiveStarted) {
        // 向所有玩家显示统计数据
        Mix_ShowAllPlayersStats();
    }

    // 重置比赛状态变量
    g_bHasMixStarted = false;
    g_bDidLiveStarted = false;
    g_bSwapNow = false;
    g_bIsKo3Running = false;
    g_bIsRandomPasswordWasLastPw = false;
    g_bIsBuyZoneDisabled = false;
    g_bIsRandomBeingUsed = false;
    g_bIsMapListGenerated = false;
    g_bIsMixMenuGenerated = false;
    g_bHasVoteMap = false;
    g_bTenVoted = false;

    // 重置回合和比分计数
    g_iCurrentRound = 1;
    g_iCurrentHalf = 1;
    g_iCTScore = 0;
    g_iTScore = 0;
    g_iCTScore2 = 0;
    g_iTScore2 = 0;
    g_iCTScoreH1 = 0;
    g_iTScoreH1 = 0;

    // 重置准备系统状态
    g_iReadyCount = 0;
    g_bAllowReady = true;
    g_bIsItManual = true;

    // 重置录制状态
    g_bIsRecording = false;
    g_bIsRecordManual = false;
    g_bSaveClientsScore = false;
    g_bClutchActive = false;
    g_iClutchPlayer = 0;
    g_iClutchUserId = 0;
    g_iClutchTeam = 0;
    g_iClutchEnemyCount = 0;

    // 重置地图和计时器状态
    Mix_StopKickUnreadyTimer();
    g_szMatchMap[0] = '\0';
    g_iSecond = 30;
    g_bKickCountdownActive = false;
    g_bIsKicked = false;

    // 重置所有玩家相关数组，但保留统计数据
    for (int i = 0; i <= MaxClients; i++)
    {
        g_bReadyPlayers[i] = false;
        g_iReadyPlayersData[i] = -1;
        g_iScoresOfTheRound[i] = 0;
        g_iScoresOfTheGame[i] = 0;
        g_iDeathsOfTheGame[i] = 0;
        g_bMutedPlayers[i] = false;
        g_bGaggedPlayers[i] = false;
        g_bHidePanel[i] = false;
        g_iLastKnownHealth[i] = 0;
    }
}

/**
 * 初始化全局变量
 *
 * 此函数在插件启动时调用，用于初始化所有全局变量为默认值。
 * 它与 Mix_ResetMatchState 函数类似，但更全面，会初始化所有全局变量。
 */
void Mix_InitGlobals()
{
    // 调用重置函数来初始化大部分变量
    Mix_ResetMatchState();

    // 初始化其他未在重置函数中处理的变量
    g_bIsMapValidToRemoveProps = true;
}
