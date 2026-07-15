extends Control

@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	status_label.text = "Prototype Gate 0: project boots"


func _on_start_pressed() -> void:
	status_label.text = "Next milestone: build the one-vehicle driving toy."
