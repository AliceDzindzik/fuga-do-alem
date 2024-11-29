extends CharacterBody2D

const GRAVITY : int = 4050
const JUMP_SPEED : int = -1370

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$Jogador.play("parado")
		else:
			$AgacharCol.disabled = true
			$CorrerCol.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				$SomPulo.play()
			elif Input.is_action_pressed("ui_down"):
				$Jogador.play("agachar")
				$CorrerCol.disabled = true
				$AgacharCol.disabled = false
			else:
				$Jogador.play("correr")
	else:
		$Jogador.play("pular")
		
	move_and_slide()
