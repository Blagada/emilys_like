extends Resource
class_name CustomerData

@export_group("Comportement")
@export var group_type: GameEnums.CustomerType
@export var speed: float = 100.0
@export var patience: float = 60.0
@export var thinking_time: float = 4.0

@export_group("Économie")
@export var tip_rate: float = 0.15

@export_group("Apparence")
@export var possible_customers: Array[CustomerVisual]
