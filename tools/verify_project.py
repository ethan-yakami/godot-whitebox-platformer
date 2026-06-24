from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "project.godot",
    "scenes/main.tscn",
    "scripts/main.gd",
    "scripts/player.gd",
    "scripts/game_state.gd",
    "scripts/input_limiter.gd",
    "scripts/hud.gd",
    "scripts/level_data.gd",
    "scripts/hazard.gd",
    "scripts/interactable.gd",
    "scripts/enemy.gd",
    "scripts/ghost.gd",
    "scripts/moving_platform.gd",
    "scripts/collapse_platform.gd",
    "scripts/components/whitebox_platform.gd",
    "scripts/components/spike_strip.gd",
    "scripts/components/water_zone.gd",
    "scripts/components/bounce_pad.gd",
    "scripts/components/checkpoint.gd",
    "scripts/components/exit_gate.gd",
    "scripts/components/stone.gd",
    "scripts/components/altar.gd",
    "scripts/components/start_view_box.gd",
    "scripts/components/jump_arc_guide.gd",
    "levels/level_1.tscn",
    "levels/level_2.tscn",
    "levels/level_3.tscn",
    "levels/level_4.tscn",
    "levels/level_5.tscn",
    "docs/01_需求文档.md",
    "docs/02_实现方案.md",
    "docs/03_资产需求文档.md",
    "docs/04_策划需求对照表.md",
    "docs/07_关卡拖拽编辑指南.md",
]

REQUIRED_TEXT = {
    "project.godot": [
        'run/main_scene="res://scenes/main.tscn"',
        'GameState="*res://scripts/game_state.gd"',
    ],
    "scripts/player.gd": [
        "extends CharacterBody2D",
        "coyote_time",
        "jump_buffer_time",
        "perform_dash",
        "consume_action",
    ],
    "scripts/main.gd": [
        "load_level",
        "LEVEL_SCENES",
        "current_level_scene",
        "award_double_jump",
        "award_legacy",
        "spawn_ghost",
        "find_child",
    ],
    "scripts/level_data.gd": [
        "outbound_limits",
        "return_limits",
        "LEVELS",
    ],
    "docs/01_需求文档.md": [
        "左/右限制指 A/D",
        "冲刺前期不可用",
        "死亡回最近路灯",
    ],
}


def main() -> int:
    missing = [path for path in REQUIRED_FILES if not (ROOT / path).exists()]
    if missing:
        print("Missing required files:")
        for path in missing:
            print(f"- {path}")
        return 1

    text_failures = []
    for rel_path, snippets in REQUIRED_TEXT.items():
        content = (ROOT / rel_path).read_text(encoding="utf-8")
        for snippet in snippets:
            if snippet not in content:
                text_failures.append(f"{rel_path}: missing {snippet!r}")

    if text_failures:
        print("Required text not found:")
        for failure in text_failures:
            print(f"- {failure}")
        return 1

    print("Project skeleton verification passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
