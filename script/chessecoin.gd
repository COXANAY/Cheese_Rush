# cheesecoin.gd

extends Area3D

signal collected

@export var rotation_speed = 2.0 # Velocidade da rotação (em radianos por segundo)

func _on_body_entered(body):
	if body is CharacterBody3D:
		collected.emit()
		queue_free()

func _process(delta):
	# Rotação no eixo Y (vertical)
	# rotate_y() é um método de Node3D (que Area3D herda)
	rotate_y(rotation_speed * delta)
	
