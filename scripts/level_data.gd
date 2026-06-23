extends Node
class_name LevelData

const LEVELS := {
	1: {
		"name": "level_1_grass",
		"title": "第一关 草原",
		"ppt_slides": "PPT Slide 4",
		"outbound_limits": {"jump": 5},
		"return_limits": {"move_left": 1},
		"reward": "double_jump",
		"route_note": "5次跳跃内通过，终点前用弹跳垫降低高台压力。",
	},
	2: {
		"name": "level_2_lake",
		"title": "第二关 湖泊",
		"ppt_slides": "PPT Slides 5-6",
		"outbound_limits": {"jump": 9},
		"return_limits": {"move_left": 5},
		"reward": "",
		"route_note": "长水流压力区，主路线通过移动平台与弹跳垫稳定通过。",
	},
	3: {
		"name": "level_3_forest",
		"title": "第三关 森林",
		"ppt_slides": "PPT Slide 7",
		"outbound_limits": {"move_left": 3},
		"return_limits": {"jump": 5},
		"reward": "",
		"route_note": "三层结构，主路线主要向右，左移只用于微调。",
	},
	4: {
		"name": "level_4_cave",
		"title": "第四关 溶洞",
		"ppt_slides": "PPT Slides 8-9",
		"outbound_limits": {"move_right": 3},
		"return_limits": {"move_left": 5},
		"reward": "attack",
		"route_note": "前半段到石碑解锁攻击，后半段进入战斗区。",
	},
	5: {
		"name": "level_5_tower",
		"title": "第五关 古塔",
		"ppt_slides": "PPT Slide 10",
		"outbound_limits": {"move_left": 4},
		"return_limits": {"move_right": 2},
		"reward": "legacy",
		"route_note": "Boss平台后解除限制，右侧献祭石获得传承。",
	},
}


static func get_level(level_number: int) -> Dictionary:
	return LEVELS.get(level_number, LEVELS[1])


static func get_limits(level_number: int, phase: String) -> Dictionary:
	var data := get_level(level_number)
	if phase == "return":
		return data.get("return_limits", {})
	return data.get("outbound_limits", {})
