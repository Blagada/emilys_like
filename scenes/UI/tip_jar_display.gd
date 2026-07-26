extends Control
class_name TipJarDisplay

@onready var tip_fund_sprite: AnimatedSprite2D = $TipFundSprite

@export var amount_per_frame: float = 10.0
@export var max_frame_index: int = 6


func _ready() -> void:
	GameDataManager.earnings_updated.connect(_update_frame)
	tip_fund_sprite.stop() # on ne joue pas d'animation, on fige juste une frame
	_update_frame()


func _update_frame() -> void:
	var target_frame: int = int(ceil(GameDataManager.tip_fund / amount_per_frame))
	tip_fund_sprite.frame = clampi(target_frame, 0, max_frame_index)
