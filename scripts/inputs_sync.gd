extends MultiplayerSynchronizer

# Possible inputs for the player.
# Set via RPC to simulate is_action_just_pressed.
# @export var jumping := false



# Synchronized property.
@export var motion := Vector2()


func _ready():
    # Only process for the local player.
    set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


# @rpc("call_local")
# func jump():
# 	jumping = true


func _process(delta):
    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    # direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var x_input = Input.get_axis("ui_left", "ui_right")
    var y_input = Input.get_axis("ui_up", "ui_down")
    motion = Vector2(x_input, y_input).normalized()
    # if Input.is_action_just_pressed("ui_accept"):
    # 	jump.rpc()
