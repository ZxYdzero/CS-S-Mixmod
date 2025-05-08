/**
 * 全局变量模块
 */

#if defined _mixmod_globals_included
  #endinput
#endif
#define _mixmod_globals_included

// =============================================================================
// 回合和比分计数相关变量
// =============================================================================
int g_iCurrentRound = 1;
int g_iCurrentHalf = 1;
int g_iCTScore = 0, g_iTScore = 0, g_iCTScore2 = 0, g_iTScore2 = 0;
int g_iCTScoreH1 = 0, g_iTScoreH1 = 0;

// =============================================================================
// 插件状态相关变量
// =============================================================================
bool g_bHasMixStarted = false;
bool g_bDidLiveStarted = false;
bool g_bSwapNow = false;
bool g_bIsKo3Running = false;
bool g_bIsRandomPasswordWasLastPw = false;
bool g_bIsBuyZoneDisabled = false;
bool g_bIsRandomBeingUsed = false;

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
Handle g_hCvarDisableSayCommand = INVALID_HANDLE;
Handle g_hCvarMapListFrom = INVALID_HANDLE;
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
Handle g_hCvarAllowManualSwitching = INVALID_HANDLE;
Handle g_hCvarDelayBeforeSwapping = INVALID_HANDLE;
Handle g_hCvarShowTkMessage = INVALID_HANDLE;
Handle g_hCvarRemovePassWhenMixIsEnded = INVALID_HANDLE;
Handle g_hCvarShowMVP = INVALID_HANDLE;
Handle g_hCvarDontRemovePropsMaps = INVALID_HANDLE;
Handle g_hCvarEnableVoiceCommands = INVALID_HANDLE;
Handle g_hPluginVersion = INVALID_HANDLE;
Handle g_hFogDelete = INVALID_HANDLE;

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
bool g_bIsRecording = false;
bool g_bIsRecordManual = false;

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
// 最后进入的玩家
// =============================================================================
char g_szLastEntered_SteamID[35];
char g_szLastEntered_Name[35];

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

// =============================================================================
// HUD相关
// =============================================================================
Handle g_hHudTimer = INVALID_HANDLE;
bool g_bHidePanel[MAXPLAYERS+1] = {false, ...};

/**
 * 重置比赛参数和玩家状态
 */
void Mix_ResetMatchState()
{
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
    g_iCurrentRound = 1;
    g_iCurrentHalf = 1;
    g_iCTScore = 0;
    g_iTScore = 0;
    g_iCTScore2 = 0;
    g_iTScore2 = 0;
    g_iCTScoreH1 = 0;
    g_iTScoreH1 = 0;
    g_iReadyCount = 0;
    g_bAllowReady = true;
    g_bIsItManual = true;
    g_bIsRecording = false;
    g_bIsRecordManual = false;
    g_bSaveClientsScore = false;
    g_szMatchMap[0] = '\0';
    g_iSecond = 30;
    g_bIsKicked = false;

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
    }
}

/**
 * 初始化全局变量
 */
void Mix_InitGlobals()
{
    g_iCurrentRound = 1;
    g_iCurrentHalf = 1;
    g_iCTScore = 0;
    g_iTScore = 0;
    g_iCTScore2 = 0;
    g_iTScore2 = 0;
    g_iCTScoreH1 = 0;
    g_iTScoreH1 = 0;

    g_bHasMixStarted = false;
    g_bDidLiveStarted = false;
    g_bSwapNow = false;
    g_bIsKo3Running = false;
    g_bIsRandomPasswordWasLastPw = false;
    g_bIsBuyZoneDisabled = false;
    g_bIsRandomBeingUsed = false;

    g_bIsMapListGenerated = false;
    g_bIsMixMenuGenerated = false;

    g_iReadyCount = 0;
    g_bAllowReady = true;
    g_bIsItManual = true;

    g_bIsRecording = false;
    g_bIsRecordManual = false;
    g_bSaveClientsScore = false;

    g_szLastEntered_SteamID = "NOT_VALID";
    g_szLastEntered_Name = "NOT_VALID";

    g_bIsMapValidToRemoveProps = true;

    g_bHasVoteMap = false;
    g_szMatchMap = "";
    g_bTenVoted = false;
    g_iSecond = 30;
    g_bIsKicked = false;

    // 重置玩家相关数组
    for (int i = 0; i <= MAXPLAYERS; i++)
    {
        g_bReadyPlayers[i] = false;
        g_iReadyPlayersData[i] = -1;
        g_iScoresOfTheRound[i] = 0;
        g_iScoresOfTheGame[i] = 0;
        g_iDeathsOfTheGame[i] = 0;
        g_bMutedPlayers[i] = false;
        g_bGaggedPlayers[i] = false;
        g_bHidePanel[i] = false;
    }
}