extends CanvasLayer

@onready var network_label: Label = $NetworkLabel
@onready var level_label: Label = $LevelLabel
@onready var is_a_game_running_label: Label = $IsAGameRunningLabel
@onready var bonus_label: Label = $BonusLabel

# Audio part
@onready var audio_bonus_picked_up: AudioStreamPlayer = $"../AudioManager/BonusPickUpAudioStreamPlayer"
@onready var audio_bonus_used: AudioStreamPlayer = $"../AudioManager/BonusUsedAudioStreamPlayer"

var number_of_players: int = 0

func _ready() -> void:
    EventBus.connect("add_player", on_player_added)
    EventBus.connect("remove_player", on_remove_player)
    EventBus.connect("start_level", on_start_level)
    EventBus.connect("is_server_running_a_busy_round", on_joining_server_running_a_busy_round)
    EventBus.connect("sync_bonus_count", on_sync_bonus_count)
    EventBus.connect("bonus_used", on_bonus_used)


func on_player_added(_player_id, _player_info) -> void:
    number_of_players += 1
    network_label.text = "Player connected: %d " % number_of_players

func on_remove_player(_player_id) -> void:
    number_of_players -= 1
    network_label.text = "Player connected: %d " % number_of_players

func on_start_level(current_level, nb_bullets) -> void:
    # Update the UI with the current level and number of bullets.
    level_label.text = "Level: %d - Bullets: %d" % [current_level, nb_bullets]

func on_joining_server_running_a_busy_round(should_display_label: bool) -> void:
    # If the game is currently running, we display the label.
    if should_display_label:
        is_a_game_running_label.show()
    else:
        is_a_game_running_label.hide()

func on_sync_bonus_count(bonus_number: int, is_bonus_picked_up: bool = false) -> void:
    bonus_label.text = " Shield: %d" % bonus_number
    if is_bonus_picked_up:
        audio_bonus_picked_up.play()  # Play the bonus picked up sound
    # Update the UI with the current bonus count.

func on_bonus_used() -> void:
    audio_bonus_used.play()  # Play the bonus used sound
