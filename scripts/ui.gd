extends CanvasLayer

@onready var network_label: Label = $NetworkLabel
@onready var level_label: Label = $LevelLabel

var number_of_players: int = 0

func _ready() -> void:
    EventBus.connect("add_player", on_player_added)
    EventBus.connect("remove_player", on_remove_player)
    EventBus.connect("start_level", on_start_level)


func on_player_added(_player_id, _player_info) -> void:
    number_of_players += 1
    network_label.text = "Player connected: %d " % number_of_players

func on_remove_player(_player_id) -> void:
    number_of_players -= 1
    network_label.text = "Player connected: %d " % number_of_players

func on_start_level(current_level, nb_bullets) -> void:
    # Update the UI with the current level and number of bullets.
    level_label.text = "Level: %d - Bullets: %d" % [current_level, nb_bullets]
