extends CharacterBody2D
# This demo is an example of controling a high number of 2D objects with logic
# and collision without using nodes in the scene. This technique is a lot more
# efficient than using instancing and nodes, but requires more programming and
# is less visual. Bullets are managed together in the `bullets.gd` script.


@export var INIT_NUMBER_OF_LIFE := 1
## The number of bullets currently touched by the player.
var touching := 0


var speed: float = 200.0

@onready var sprite_size: Vector2 = ($Sprite2D.texture.get_size() * scale) / 2

var number_of_life := INIT_NUMBER_OF_LIFE
var is_invincible: bool = true # used with safe zone, can be used later to make the player invincible for a short time after being hit.
var is_hidden: bool = false # used when the player should be hidden

var init_position = position
@export var synced_position := Vector2()
# @onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var state_machine : Node = $StateMachine

var peer_id = 0
var motion:= Vector2()

@onready var sync = $MultiplayerSynchronizer

func _ready() -> void:
    material.set_shader_parameter("enable_effect", false)
    print("player.gd - _ready() - id: " + str(peer_id) + " - is_multiplayer_authority: " + str(is_multiplayer_authority()))
    
    # EventBus.connect("player_respawned", _on_player_respawned)
    # The player follows the mouse cursor automatically, so there's no point
    # in displaying the mouse cursor.
    # Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)



func _physics_process(delta: float) -> void:
    if is_hidden:
        return  # If the player is hidden, we don't process anything.
    if multiplayer == null or is_multiplayer_authority():
        var x_input = Input.get_axis("ui_left", "ui_right")
        var y_input = Input.get_axis("ui_up", "ui_down")
        motion = Vector2(x_input, y_input).normalized()
        synced_position = position
    else:
        position = synced_position

    # TODO: Fix state machine later
    # # If the player is not moving, we don't need to update the state machine
    # if x_input == 0 and y_input == 0 and state_machine.current_state is not PlayerIdle:
    #     state_machine.current_state.emit_signal("transitioned", state_machine.current_state, "PlayerIdle")
    # elif x_input != 0 or y_input != 0:
    #     # If the player is moving, we can transition to the walking state
    #     if state_machine.current_state is not PlayerWandering:
    #         state_machine.current_state.emit_signal("transitioned", state_machine.current_state, "PlayerWandering")

    # Move the player according to the inputs
    
    # synced_position = position
    # else:
    #     position = synced_position
        # If this is not the authority, we just update the position
        # based on the motion vector.
    # position += motion * delta
    
    # Getting the movement of the mouse so the sprite can follow its position.
    # if event is InputEventMouseMotion:
    #     position = event.position - Vector2(0, 16)

    # # Get input from the joystick
    # var x_input = Input.get_axis("ui_left", "ui_right")
    # var y_input = Input.get_axis("ui_up", "ui_down")

    # If the player is not moving, we don't need to update the state machine
    if not motion and state_machine.current_state is not PlayerIdle:
        state_machine.current_state.emit_signal("transitioned", state_machine.current_state, "PlayerIdle")
    elif motion:
        # If the player is moving, we can transition to the walking state
        if state_machine.current_state is not PlayerWandering:
            state_machine.current_state.emit_signal("transitioned", state_machine.current_state, "PlayerWandering")
        

    # Move the player according to the inputs
    # var direction = Vector2(x_input, y_input).normalized()
    velocity = motion * speed
    move_and_slide()
    # position += motion * speed * delta

    # Clamp the player's position to stay within the screen bounds
    var screen_size = get_viewport_rect().size
    position.x = clamp(position.x, 0 + sprite_size.x , screen_size.x - sprite_size.x)
    position.y = clamp(position.y, 0 + sprite_size.y, screen_size.y - sprite_size.y)


func _on_body_shape_exited(_body_id: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
    touching -= 1
    # When non of the bullets are touching the player,
    # sprite changes to happy face.
    if touching == 0:
        material.set_shader_parameter("enable_effect", false)
        # sprite.frame = 0


func _on_area_entered(area: Area2D) -> void:
    # print("The star is touched 2 - area group: ", area.get_groups())
    if "star" in area.get_groups():
        if multiplayer == null or is_multiplayer_authority(): # Only the authority should emit the signal.
            print("The star is touched 3")
            EventBus.emit_signal("star_touched", name)
    if "safeZone" in area.get_groups():
        if multiplayer == null or is_multiplayer_authority(): # Only the authority should emit the signal.
            print("The safezone is entered by the player")
            is_invincible = true
    if "bonus" in area.get_groups():
        if multiplayer == null or is_multiplayer_authority(): # Only the authority should emit the signal.
            print("The bonus is touched by the player")
            EventBus.emit_signal("bonus_touched", area.name)  # Emit a signal to notify the game logic that the player touched a bonus
            print("Bonus touched: ", area.name)
    pass # Replace with function body.

func _on_area_exited(area: Area2D) -> void:
    if "safeZone" in area.get_groups():
        if multiplayer == null or is_multiplayer_authority(): # Only the authority should emit the signal.
            print("The safezone is left by the player")
            is_invincible = false
    pass # Replace with function body.


func _on_detection_area_body_shape_entered(body_rid:RID, body:Node2D, body_shape_index:int, local_shape_index:int) -> void:
    if multiplayer != null and  not is_multiplayer_authority(): # If this is not the authority, we don't process the hit.
        return
    if is_invincible: # Do nothing if the player is invincible.
        return
    # If the player is invincible, we don't want to decrease the number of lives.
    print("Player touched by a bullet")
    touching += 1
    number_of_life -= 1
    EventBus.emit_signal("player_hit", name, number_of_life)
    if touching >= 1:
        material.set_shader_parameter("enable_effect", true)
        # sprite.frame = 1
    pass # Replace with function body.


func hide_player() -> void:
    # This function is called when the player is hit and should be hidden.
    # It can be used to hide the player sprite or disable player controls.
    print("Hiding player: " + name)
    is_hidden = true
    # Hide the player sprite
    $Sprite2D.visible = false
    $DetectionArea.monitoring = false
    # Disable player controls
    $StateMachine.current_state.emit_signal("transitioned", $StateMachine.current_state, "PlayerIdle")

func reset_player(new_position: Vector2) -> void:
    # This function is called when the player is respawned.
    is_hidden = false
    position = new_position
    synced_position = new_position
    number_of_life = INIT_NUMBER_OF_LIFE
    is_invincible = true  # Reset the invincibility state
    touching = 0  # Reset the number of bullets touching the player
    # Showing the player sprite and enabling the detection area
    $Sprite2D.visible = true
    $DetectionArea.monitoring = true
    material.set_shader_parameter("enable_effect", false)
