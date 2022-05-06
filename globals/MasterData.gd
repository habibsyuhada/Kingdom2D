extends Node2D
		
var building = {
	"keep":{
		"cost":{
			"wood": 1000,
			"food": 1000,
			"stone": 1000,
		},
		"territory": 16,
		"max_people": 2,
		"max_storage": 200,
		"build_time": 100,
	},
	"wheat_field":{
		"cost":{
			"wood": 5
		},
		"territory": 8,
		"max_people": 0,
		"max_storage": 0,
		"build_time": 5,
	},
	"house":{
		"cost":{
			"wood": 10,
			"food": 10,
		},
		"territory": 8,
		"max_people": 2,
		"max_storage": 0,
		"build_time": 25,
	},
	"melee_barrack":{
		"cost":{
			"wood": 20,
			"food": 20,
		},
		"territory": 8,
		"max_people": 2,
		"max_storage": 0,
		"build_time": 25,
	},
	"ranged_barrack":{
		"cost":{
			"wood": 30,
			"food": 25,
		},
		"territory": 8,
		"max_people": 2,
		"max_storage": 0,
		"build_time": 25,
	},
}

var unit = {
	"worker":{
		"cost":{
			"wood": 5,
			"food": 5,
		},
		"build_time": 15,
	},
	"swordman":{
		"cost":{
			"wood": 15,
			"food": 15,
		},
		"build_time": 25,
	},
}
