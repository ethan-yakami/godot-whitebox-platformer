from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def require(path: str, snippets: list[str]) -> list[str]:
    file_path = ROOT / path
    if not file_path.exists():
        return [f"{path}: file missing"]
    text = file_path.read_text(encoding="utf-8")
    return [f"{path}: missing {snippet!r}" for snippet in snippets if snippet not in text]


def main() -> int:
    failures = []
    failures += require("scripts/player.gd", [
        'Input.is_action_just_pressed("move_left")',
        'Input.is_action_just_released("move_left")',
        '_move_press_allowed',
        'cost = 2',
        'GameState.has_dash',
        'invincible_time',
        'flash_timer',
        "limit_denied",
        "void_recover",
        "GameState.has_attack",
        "jump_velocity := -775.0",
        "body.position = Vector2(-whitebox_size.x * 0.5, -whitebox_size.y)",
    ])
    failures += require("scripts/game_state.gd", [
        "var max_ghosts := 2",
        "ghost_positions.pop_front()",
        "phase = PHASE_RETURN",
        "max_health = 5",
        "has_attack",
        "award_attack",
    ])
    failures += require("scripts/main.gd", [
        'if GameState.current_level == 1:',
        "LEVEL_SCENES",
        "current_level_scene",
        "find_child(\"SpawnPoint\"",
        "find_child(\"ReturnSpawnPoint\"",
        "award_double_jump()",
        "award_legacy()",
        'if GameState.phase != GameState.PHASE_RETURN:',
        "player.respawn_at(GameState.checkpoint_position)",
        "_boss_defeated",
        "restart_current_level",
        "restart_run",
        "load_checkpoint",
        "_on_exit_entered",
        "defeated.connect",
        "_get_level_spawn",
        "exit_position + Vector2(-120, 0)",
        'limiter.configure({})',
        "_on_stone_activated",
        "_apply_level_layout_overrides",
        "_try_gm_level_shortcuts",
        "_ensure_progression_unlocks",
        "KEY_1",
        "load_level(debug_level)",
        "GameState.current_level >= 2 and not GameState.has_double_jump",
    ])
    failures += require("scripts/level_editor.gd", [
        "class_name LevelEditor",
        "LEVEL_SCENES",
        "_selected",
        "_resize_mode",
        "_save_layout",
        "_load_layout_overrides",
        "Ctrl+S",
        "has_method(\"set\")",
    ])
    failures += require("scenes/level_editor.tscn", [
        "LevelEditor",
        "res://scripts/level_editor.gd",
    ])
    for level in range(1, 6):
        failures += require(f"levels/level_{level}.tscn", [
            "SpawnPoint",
            "ReturnSpawnPoint",
            "Checkpoint",
            "ExitGate",
            "Route",
        ])
    failures += require("levels/level_1.tscn", [
        "J1_ToLowFloat",
        "J2_ToPinkStep",
        "J3_ToMidPink",
        "J4_AirJumpBlocker",
        "J5_ToExit",
        "air jump",
    ])
    failures += require("levels/level_2.tscn", [
        "Scene1",
        "Scene2",
        "DropMomentum",
        "NoJumpGlide",
        "J9_FinalClimb",
        "inertia",
        "moving_spike.gd",
        "S_FinalWallTeeth",
        "offset = Vector2(-1080, 0)",
        "S2_OrangeInWater",
        "bounce_height",
    ])
    failures += require("levels/level_3.tscn", [
        "P_TopCheckpoint",
        "HZ_MovingSpikeLane_Top",
        "HZ_MovingSpikeLane_Mid",
        "S_MoverTop",
        "S_MoverMid",
        "M_LowGreenPlatform",
        "M_MidGreenPlatform",
        "P_CollapseMid",
        "B_MidOrange",
        "Berry_Forest",
        "Stone_ForestLore",
        "GreenStartOutbound",
        "BlackStartReturn",
        "PPT7 exact-legend rebuild",
    ])
    failures += require("levels/level_4.tscn", [
        "P4_Scene1_StartFloor",
        "P4_Scene1_TopBridge",
        "P4_Scene2_LeftTower",
        "P4_Scene2_FinalShelf",
        "HZ4_Scene1_MovingSpikeLane",
        "HZ4_Scene2_CenterDrop",
        "M4_Scene1_GreenMover",
        "M4_Scene2_GreenMover",
        "B4_Scene2_OrangePad_A",
        "Berry_Cave",
        "Stone_AttackUnlock",
        "BlackStartReturn",
        "PPT8-9 exact-legend rebuild",
    ])
    failures += require("levels/level_5.tscn", [
        "P5_StartFloor",
        "P5_LongBossWalk",
        "P5_AltarFloor",
        "HZ5_CeilingMover",
        "M5_LeftGreenMover",
        "B5_LowerOrangePad",
        "C5_LowerPink",
        "Berry_Tower",
        "legacy_boss",
        "Altar_Legacy",
        "BlackBossDrop",
        "PPT10 exact-legend rebuild",
    ])
    for component in [
        "whitebox_platform",
        "spike_strip",
        "moving_spike",
        "water_zone",
        "bounce_pad",
        "checkpoint",
        "exit_gate",
        "stone",
        "altar",
    ]:
        failures += require(f"scripts/components/{component}.gd", [
            "@tool",
            "@export",
            "_rebuild",
        ])
    failures += require("scripts/components/jump_arc_guide.gd", [
        "@tool",
        "class_name JumpArcGuide",
        "player_speed := 256.0",
        "jump_velocity := -775.0",
        "gravity := 1600.0",
        "player_size := Vector2(48, 64)",
        "show_player_samples",
        "player_sample_count",
        "_draw_player_box",
        "_draw_player_samples",
        "normal_jump_color",
        "fall_inertia_color",
        "player_box_fill_color",
        "player_box_outline_color",
        "Engine.is_editor_hint()",
        "draw_polyline",
        "draw_string",
    ])
    jump_arc_text = (ROOT / "scripts/components/jump_arc_guide.gd").read_text(encoding="utf-8")
    for forbidden in ["double_jump_color", "_make_double_jump_points", "double jump"]:
        if forbidden in jump_arc_text:
            failures.append(f"scripts/components/jump_arc_guide.gd: forbidden {forbidden!r}")
    failures += require("scripts/moving_platform.gd", [
        "_draw",
        "draw_line",
        "draw_circle",
        "queue_redraw",
        "bounce_height",
        "BounceTrigger",
        "Area2D.new()",
        "body.bounce(",
        "sqrt(2.0 * body.gravity * bounce_height)",
    ])
    failures += require("scripts/components/moving_spike.gd", [
        "class_name MovingSpike",
        "offset := Vector2(128, 0)",
        "speed := 128.0",
        "_physics_process",
        "global_position = _origin.lerp(_origin + offset, alpha)",
        "Polygon2D",
        "body_entered.connect",
        "body.take_damage(damage)",
    ])
    failures += require("docs/07_关卡拖拽编辑指南.md", [
        "MovingPlatform",
        "bounce_height",
        "橙色移动平台",
    ])
    failures += require("levels/level_1.tscn", [
        "JumpArcGuide",
        "Arc_J1",
        "Arc_J4_AirJump",
    ])
    failures += require("levels/level_2.tscn", [
        "JumpArcGuide",
        "Arc_Scene1",
        "Arc_Scene2",
    ])
    failures += require("scripts/hud.gd", [
        "rules_panel",
        "legend_panel",
        "Resume",
        "Load Checkpoint",
        "Restart Level",
        "Restart Run",
        "攻击",
        "A/D 左右移动",
        "H 跳跃",
        "R 重开当前关",
        "GM 1-5 直跳关卡",
        "蓝色矩形：玩家",
        "灰色平台：安全落脚",
        "粉色平台：塌陷平台",
        "浅黄区域：水流/危险槽",
        "蓝色尖刺：伤害",
    ])
    failures += require("scripts/enemy.gd", [
        "signal defeated",
        "defeated.emit",
    ])
    failures += require("scripts/collapse_platform.gd", [
        "extends StaticBody2D",
        "collapse_delay",
        "queue_free",
    ])
    failures += require("project.godot", [
        "load_checkpoint",
        "restart",
        "keycode\":76",
        "keycode\":82",
    ])
    failures += require("scripts/level_data.gd", [
        '"jump": 5',
        '"move_left": 1',
        '"move_right": 3',
        '"move_right": 2',
    ])
    if failures:
        print("Behavior check failures:")
        for failure in failures:
            print(f"- {failure}")
        return 1
    print("Behavior checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
