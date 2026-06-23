# 关卡配置表.xlsx

## Sheet: Sheet1
|  | name | W | H |  |  |  |  | 备注 |  |
| 场景/角色参考尺寸(32px=1格） | 屏幕分辨率 | W：60格 | H：33.75格 |  |  |  |  | 1920×1080 |  |
|  | 角色视野大小 | W：15格 | H：10格 |  |  |  |  |  |  |
|  | 角色碰撞体积大小 | W：3格 | H：4格 |  |  |  |  | camera center 跟随角色移动 |  |
|  | 平台宽度 | 2格 |  |  |  |  |  |  |  |
|  | 平台长度 | 长平台：5格 | 短平台：3格 |  |  |  |  |  |  |
|  | 平台高度 | 根据关卡设计调整，一般距离起跳点3-3.5格高，关卡设计中距离起跳点明显较高的5-7格 |  |  |  |  |  |  |  |
| 关卡资源 | name | hurt | move_range | force | trigger_range | cd | speed_move |  |  |
|  | spine | 1 | / | / | 0 | / | / |  |  |
|  | move_spine | 1 | dynamic | / | 5 | 5s | 9格/s |  |  |
|  | river | 0 | / | 4格/s | 0 | / | / |  |  |
|  | o_t | 2 | / | / | 0 | / | / |  |  |
|  | pad_move | 0 | 4 | / | 0 | 0 | 4格/s |  |  |
|  | pad_collapse | 0 | / | / | 0 | / | / |  |  |
|  | pad_bounce | 0 | / | 6 | 0 | / | / |  |  |
| 角色/npc/怪物属性 | name | speed_move | range_attack | range_trigger | jump_h | cd | shape_size | function（chat=1/fight=0/play=10) | text |
|  | monster | 暂略 |  |  |  |  |  | 0 | 待完善 |
|  | npc | / | / | 3 | / | / | （3，4） | 1 |  |
|  | boss_L1 | 暂略 |  |  |  |  | （6，8） | 0,1 |  |
|  | boss_L2 |  |  |  |  |  | （6，8） | 0 |  |
|  | boss_L3 |  |  |  |  |  | （6，8） | 1 |  |
|  | player | 8 | 3 | / | 4 |  | （3，4） | 10 |  |

## Sheet: Sheet2

## Sheet: Sheet3
