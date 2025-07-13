# Event bus to communicate between nodes
extends Node

signal player_hit
signal player_died
signal respawn_player
signal star_touched
signal add_player # Signal to synchronize player data across peers when a new player connects
signal remove_player # Signal to remove player data across peers when a player disconnects
signal set_player_node_name_and_init_position # Signal to set the player node name for synchronization

signal bullets_init_and_start # Signal sent on server to spawn bullets (the server is running the randomization and send to clients)
signal start_level # Signal to update the UI with the current level and number of bullets (sent from server)

signal is_server_running_a_busy_round # Signal to indicate if a game is currently running - UI will display the label accordingly


# Signal linked to bonus
signal bonus_touched # Signal to notify the game logic that a player touched a bonus
signal sync_bonus_count # Signal to notify the UI that a player touched a bonus