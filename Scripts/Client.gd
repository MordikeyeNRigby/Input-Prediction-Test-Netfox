class_name Client extends Node

var username: String #unused for now but i usually add usernames
var id: int
const selfScene: PackedScene = preload("res://Client.tscn")
var character: Character

func Delete():
	character.queue_free()
	queue_free()


static func Instantiate(id: int) -> Client:
	var c: Client = selfScene.instantiate()
	c.id = id
	return c
