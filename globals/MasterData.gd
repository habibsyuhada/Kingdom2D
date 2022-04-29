extends Node2D
		
var building = {
	"keep":{
		"cost":{
			"wood": 1000,
			"food": 1000,
			"stone": 1000,
		},
		"territory": 8,
		"max_people": 2,
		"max_storage": 200,
		"build_time": 100,
	},
	"wheat_field":{
		"cost":{
			"wood": 5
		},
		"territory": 2,
		"max_people": 0,
		"max_storage": 0,
		"build_time": 5,
	},
	"house":{
		"cost":{
			"wood": 100,
			"food": 75,
		},
		"territory": 2,
		"max_people": 2,
		"max_storage": 0,
		"build_time": 25,
	},
}

var unit = {
	"worker":{
		"cost":{
			"wood": 50,
			"food": 75,
		},
		"build_time": 25,
	},
}
