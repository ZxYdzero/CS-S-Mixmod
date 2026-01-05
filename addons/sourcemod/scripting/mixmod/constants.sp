/**
 * 常量定义模块
 *
 * 本模块包含插件使用的所有常量定义，集中管理以便于维护和更新。
 */

#if defined _mixmod_constants_included
  #endinput
#endif
#define _mixmod_constants_included

// =============================================================================
// 插件常量
// =============================================================================
#define PLUGIN_VERSION "5.3"
#define MODNAME "MYGO"

// =============================================================================
// 权限和团队定义
// =============================================================================
#define ACCESS_FLAG ADMFLAG_KICK  // 管理员命令所需的权限标志

// 使用CS:S内置的团队常量，避免重复定义
// 这些定义仅在CS团队常量未定义时使用
#if !defined CS_TEAM_NONE
#define CS_TEAM_NONE        0
#endif

#if !defined CS_TEAM_SPECTATOR
#define CS_TEAM_SPECTATOR   1
#endif

#if !defined CS_TEAM_T
#define CS_TEAM_T           2
#endif

#if !defined CS_TEAM_CT
#define CS_TEAM_CT          3
#endif

// 为了向后兼容保留的团队常量
#define TEAM_SPEC CS_TEAM_SPECTATOR
#define TEAM_T CS_TEAM_T
#define TEAM_CT CS_TEAM_CT
#define TEAM_ONE CS_TEAM_T
#define TEAM_TWO CS_TEAM_CT

// =============================================================================
// 地图相关常量
// =============================================================================
#define MAX_MAPS 50  // 最大地图数量

// =============================================================================
// 消息颜色常量
// =============================================================================
#define COLOR_PREFIX "\x04"  // 前缀颜色（通常为绿色）
#define COLOR_NORMAL "\x01"  // 普通文本颜色
#define COLOR_HIGHLIGHT "\x03"  // 高亮文本颜色（通常为黄色）
#define COLOR_TEAM1 "\x03"  // 队伍1颜色
#define COLOR_TEAM2 "\x03"  // 队伍2颜色

// =============================================================================
// 文件路径常量
// =============================================================================
#define CONFIG_FILENAME "sm_mixmod"  // 配置文件名称（不含扩展名）

/**
 * 初始化常量模块
 *
 * 此函数在插件启动时调用，用于初始化任何需要动态设置的常量。
 * 目前没有需要动态初始化的常量，但保留此函数以便将来扩展。
 */
void Mix_InitConstants()
{
    // 目前没有需要动态初始化的常量
    // 此函数保留用于将来可能的扩展
}