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
    ])
    for component in [
        "whitebox_platform",
        "spike_strip",
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
        "jump_velocity := -560.0",
        "gravity := 1600.0",
        "normal_jump_color",
        "double_jump_color",
        "fall_inertia_color",
        "Engine.is_editor_hint()",
        "draw_polyline",
        "draw_string",
    ])
    failures += require("scripts/moving_platform.gd", [
        "_draw",
        "draw_line",
        "draw_circle",
        "queue_redraw",
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
        "Resume",
        "Load Checkpoint",
        "Restart Level",
        "Restart Run",
        "攻击",
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
