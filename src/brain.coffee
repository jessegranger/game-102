class Impulse
	constructor: (@unit) ->

class ChaseImpulse extends Impulse
	net = new synaptic.Architect.Liquid(8, 32, 4, 16, 4)
	$.log "Training ChaseImpulse..."
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
	$.log "Training BorderImpulse..."
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
	$.log "Training RushImpulse..."
	net.trainer.train trainingSet = [
		{ input: [ 0,0,0,0,0,0,0,0 ], output: actUp } # run forward when totally clear
		{ input: [ 1,0,0,0,0,0,0,0 ], output: actRight }
		{ input: [ 1,.5,0,0,0,0,0,1 ], output: actRight }
		{ input: [ 0,1,0,0,0,0,0,0 ], output: actUpRight  }
		{ input: [ 1,0,0,0,0,0,.5,1 ], output: actLeft }
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

$.log "Training finished..."
class Brain
	constructor: (@unit, impulses...) ->
		@impulses = impulses.map (T) => new T @unit
	react: (world, frame) ->
		reaction = $.zeros(4)
		n = 4
		for impulse in @impulses
			for x,i in impulse.react(world, frame).map $.random.coin
				reaction[i] |= x