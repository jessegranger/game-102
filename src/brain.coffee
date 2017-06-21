
actIdle  = [0,0,0,0]
actUp    = [1,0,0,0]
actRight = [0,1,0,0]
actDown  = [0,0,1,0]
actLeft  = [0,0,0,1]
actUpLeft = [1,0,0,1]
actUpRight = [1,1,0,0]
actDownLeft = [0,0,1,1]
actDownRight = [0,1,1,0]

class Impulse
	constructor: (@unit) ->

class ChaseImpulse extends Impulse
	net = new synaptic.Architect.Liquid 8, 32, 4, 16, 4
	$.log "Training Chase..."
	net.trainer.train trainingSet = [
		{ input: [ 0,0,0,0,0,0,0,0 ], output: actIdle }
		{ input: [ 1,0,0,0,0,0,0,0 ], output: actUp }
		{ input: [ 0,1,0,0,0,0,0,0 ], output: actUpLeft }
		{ input: [ 0,0,1,0,0,0,0,0 ], output: actLeft }
		{ input: [ 0,0,0,1,0,0,0,0 ], output: actDownLeft }
		{ input: [ 0,0,0,0,1,0,0,0 ], output: actDownRight }
		{ input: [ 0,0,0,0,0,1,0,0 ], output: actRight }
		{ input: [ 0,0,0,0,0,0,1,0 ], output: actUpRight }
		{ input: [ 0,0,0,0,0,0,0,1 ], output: actUp }
		{ input: [ 0,0,0,0,0,0,0,0 ], output: actIdle }
		{ input: [ .5,0,0,0,0,0,0,0 ], output: actUp }
		{ input: [ 0,.5,0,0,0,0,0,0 ], output: actUpLeft }
		{ input: [ 0,0,.5,0,0,0,0,0 ], output: actLeft }
		{ input: [ 0,0,0,.5,0,0,0,0 ], output: actDownLeft }
		{ input: [ 0,0,0,0,.5,0,0,0 ], output: actDownRight }
		{ input: [ 0,0,0,0,0,.5,0,0 ], output: actRight }
		{ input: [ 0,0,0,0,0,0,.5,0 ], output: actUpRight }
		{ input: [ 0,0,0,0,0,0,0,.5 ], output: actUp }
	]
	constructor: (unit, @target) ->
		super unit
	react: (world, frame) ->
		net.activate Float64Array.from \
			@unit.getGrid frame, (obj) => obj is @target

class BorderImpulse extends Impulse
	net = new synaptic.Architect.Liquid 4, 32, 4, 16, 4
	$.log "Training Border..."
	net.trainer.train trainingSet = [
		{ input: [ 0,0,0,0 ], output: actIdle }
		{ input: [ 1,0,0,0 ], output: actIdle }
		{ input: [ 0,1,0,0 ], output: actLeft }
		{ input: [ 0,0,1,0 ], output: actUp }
		{ input: [ 0,0,0,1 ], output: actRight }
	]
	react: (world, frame) ->
		net.activate Float64Array.from [
			+(@unit.y < 0),
			+(@unit.x > 52),
			+(@unit.y > 100),
			+(@unit.x < 1),
		]

class RushImpulse extends Impulse
	net = new synaptic.Architect.Liquid 8, 32, 4, 16, 4
	$.log "Training Rush..."
	net.trainer.train trainingSet = [
		{ input: [ 0,0,0,0,0,0,0,0 ], output: actUp } # run forward when totally clear
		{ input: [ 1,0,0,0,0,0,0,0 ], output: actRight }
		{ input: [ 1,.5,0,0,0,0,0,1 ], output: actRight }
		{ input: [ .5,1,0,0,0,0,0,1 ], output: actUp }
		{ input: [ 0,1,0,0,0,0,0,0 ], output: actUpRight  }
		{ input: [ 1,0,0,0,0,0,.5,1 ], output: actLeft }
		{ input: [ 1,0,0,0,0,0,1,.5 ], output: actUpRight }
		{ input: [ 0,0,1,0,0,0,0,0 ], output: actUp }
		{ input: [ 0,0,0,1,0,0,0,0 ], output: actUp }
		{ input: [ 0,0,0,0,1,0,0,0 ], output: actUp }
		{ input: [ 0,0,0,0,0,1,0,0 ], output: actUp }
		{ input: [ 0,0,0,0,0,0,1,0 ], output: actUpLeft }
		{ input: [ 0,0,0,0,0,0,0,1 ], output: actLeft }
	]
	react: (world, frame) ->
		net.activate Float64Array.from \
			@unit.getGrid frame, (obj) => obj.team? and obj.team isnt @unit.team

class Brain
	constructor: (@unit, impulses...) ->
		@impulses = impulses.map (T) => new T @unit
	react: (world, frame) ->
		reaction = $.zeros(4)
		for impulse in @impulses
			for x,i in impulse.react(world, frame).map $.random.coin
				reaction[i] |= +x
		reaction
