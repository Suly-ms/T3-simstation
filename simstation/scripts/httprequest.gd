extends Node

var http = HTTPRequest.new()

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("sauvegarder")):
		var url = "https://simstation-33519-default-rtdb.firebaseio.com/habitants.json"
		var headers = ["Content-Type: application/json"]
		var data = {"habitants": Global.population.size()}
		var json_data = JSON.stringify(data)
		http.request(url, headers, HTTPClient.METHOD_PUT, json_data)
