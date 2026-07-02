extends Node2D
class_name BaseCustomerSkin

@onready var sprite_customer: Sprite2D = $SpriteCustomer
@onready var animated_customer: AnimatedSprite2D = $AnimatedCustomer

func on_state_changed(new_state, target_pos):
	match new_state:
		GameEnums.CustomerState.MOVING:
			update_orientation(target_pos)
			#animated_customer.play("walk")
		GameEnums.CustomerState.SITTING:
			update_orientation(target_pos)
			#animated_customer.play("sit")
		#idle, eat
		

func update_orientation(target_position: Vector2):
	# Si le client est à gauche de la cible, il regarde à droite (flip_h = false)
	# Si le client est à droite de la cible, il regarde à gauche (flip_h = true)
	sprite_customer.flip_h = global_position.x > target_position.x
	print ("flip ou pas, ", sprite_customer.flip_h)
