from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    failures = []
    for script in (ROOT / "scripts").glob("*.gd"):
        text = script.read_text(encoding="utf-8")
        if "\t" not in text and "func " in text:
            failures.append(f"{script}: expected tab-indented GDScript blocks")
        for match in re.finditer(r'preload\("res://([^"]+)"\)', text):
            rel = match.group(1)
            if not (ROOT / rel).exists():
                failures.append(f"{script}: missing preload target res://{rel}")
        if "InputLimiter" in text and script.name != "input_limiter.gd":
            if not (ROOT / "scripts" / "input_limiter.gd").exists():
                failures.append(f"{script}: InputLimiter referenced but file missing")

    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    for action in ["move_left", "move_right", "look_up", "look_down", "jump", "dash", "attack_interact", "pause"]:
        if f"{action}=" not in project:
            failures.append(f"project.godot: missing input action {action}")

    if failures:
        print("Static check failures:")
        for failure in failures:
            print(f"- {failure}")
        return 1
    print("Static checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
