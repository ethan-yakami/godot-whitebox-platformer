from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
GUIDE_SCRIPT = ROOT / "scripts" / "components" / "jump_arc_guide.gd"
SIZE_GUIDE_SCRIPT = ROOT / "scripts" / "components" / "player_size_guide.gd"
PLAYER_SCRIPT = ROOT / "scripts" / "player.gd"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def main() -> int:
    failures = []
    guide_text = _read(GUIDE_SCRIPT)
    size_guide_text = _read(SIZE_GUIDE_SCRIPT) if SIZE_GUIDE_SCRIPT.exists() else ""
    player_text = _read(PLAYER_SCRIPT)

    for token in [
        "sync_with_player_defaults",
        "player_script_path",
        "_sync_player_defaults",
        "_extract_float_default",
        "FileAccess.get_file_as_string",
    ]:
        if token not in guide_text:
            failures.append(f"{GUIDE_SCRIPT}: missing {token}")

    for token in ["@export var speed", "@export var jump_velocity"]:
        if token not in player_text:
            failures.append(f"{PLAYER_SCRIPT}: missing {token}")
    if "var gravity" not in player_text:
        failures.append(f"{PLAYER_SCRIPT}: missing gravity default")

    for token in [
        "class_name PlayerSizeGuide",
        "sync_with_player_defaults",
        "player_script_path",
        "_sync_player_defaults",
        "_extract_vector2_default",
        "FileAccess.get_file_as_string",
        "Engine.is_editor_hint()",
    ]:
        if token not in size_guide_text:
            failures.append(f"{SIZE_GUIDE_SCRIPT}: missing {token}")

    for index in range(1, 6):
        level_path = ROOT / "levels" / f"level_{index}.tscn"
        if not level_path.exists():
            failures.append(f"missing {level_path}")
            continue
        level_text = _read(level_path)
        has_guide_resource = "jump_arc_guide.gd" in level_text
        has_guide_node = "JumpArcGuide" in level_text
        has_size_guide_resource = "player_size_guide.gd" in level_text
        has_size_guide_node = "PlayerSizeGuide" in level_text
        if not has_guide_resource or not has_guide_node:
            failures.append(f"{level_path}: missing editor-only JumpArcGuide reference node")
        if not has_size_guide_resource or not has_size_guide_node:
            failures.append(f"{level_path}: missing editor-only PlayerSizeGuide reference node")
        if has_guide_resource or has_guide_node:
            for property_name in ["player_speed", "jump_velocity", "gravity"]:
                pattern = rf"^{property_name}\s*="
                if re.search(pattern, level_text, re.MULTILINE):
                    failures.append(
                        f"{level_path}: JumpArcGuide should sync {property_name} from Player defaults"
                    )

    if failures:
        print("Jump arc guide verification failures:")
        for failure in failures:
            print(f"- {failure}")
        return 1
    print("Jump arc guide verification passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
