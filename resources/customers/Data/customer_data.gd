extends Resource
class_name CustomerData

@export var group_type: GameEnums.CustomerType
@export var speed: float = 100.0
@export var patience: float = 60.0
@export var tip_multiplier: float = 1.0
@export var possible_customers: Array[CustomerVisual]
