
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
	sense: (world, frame) -> [ 0 ]
	react: (world, frame) -> actIdle

class Brain # loosely supervise a set of impulses
	constructor: (@unit, impulses...) ->
		@impulses = $ impulses.map (T) => new T @unit
	sense: (world, frame) ->
		@impulses.select('sense').call(world,frame)
	react: (world, frame) ->
		action = $.zeros(4)
		for impulse in @impulses
			# each time an impulse reacts, like: [ .75, .25, .10, .00 ]
			# we flip 4 weighted coins to get: [ 1, 1, 0, 0 ]
			# (with a 75% chance, 25% chance, 10% chance, etc)
			# then for now we 'or' all the reactions together
			# could possibly average them or use a reinforcement strategy to learn a dynamic blend
			for x,i in impulse.react(world, frame).map((w) -> +$.random.coin w)
				action[i] |= +x
		action
	retrain: ->
		@impulses.select('retrain').call()

ChaseImpulse = do ->
	net = new synaptic.Architect.Liquid 8, 32, 4, 16, 4
	$.log "Training the impulse to chase the ball..."
	net.trainer.train trainingSet = [
		{ input: [  0,0,0,0,0,0,0,0 ], output: actIdle }
		{ input: [  1,0,0,0,0,0,0,0 ], output: actUp }
		{ input: [ 0, 1,0,0,0,0,0,0 ], output: actUpLeft }
		{ input: [ 0,0, 1,0,0,0,0,0 ], output: actLeft }
		{ input: [ 0,0,0, 1,0,0,0,0 ], output: actDownLeft }
		{ input: [ 0,0,0,0, 1,0,0,0 ], output: actDownRight }
		{ input: [ 0,0,0,0,0, 1,0,0 ], output: actRight }
		{ input: [ 0,0,0,0,0,0, 1,0 ], output: actUpRight }
		{ input: [ 0,0,0,0,0,0,0, 1 ], output: actUp }
		{ input: [ 0,0,0,0,0,0,0,0  ], output: actIdle }
		{ input: [ .5,0,0,0,0,0,0,0 ], output: actUp }
		{ input: [ 0,.5,0,0,0,0,0,0 ], output: actUpLeft }
		{ input: [ 0,0,.5,0,0,0,0,0 ], output: actLeft }
		{ input: [ 0,0,0,.5,0,0,0,0 ], output: actDownLeft }
		{ input: [ 0,0,0,0,.5,0,0,0 ], output: actDownRight }
		{ input: [ 0,0,0,0,0,.5,0,0 ], output: actRight }
		{ input: [ 0,0,0,0,0,0,.5,0 ], output: actUpRight }
		{ input: [ 0,0,0,0,0,0,0,.5 ], output: actUp }
	]
	(target) ->
		class _ChaseImpulse extends Impulse
			constructor: (unit) ->
				super unit
			sense: (world, frame) ->
				@unit.getGrid frame, (obj) => obj is target
			react: (world, frame) ->
				net.activate Float64Array.from @sense world, frame
			retrain: -> net.trainer.train trainingSet

class BorderImpulse extends Impulse
	net = new synaptic.Architect.Liquid 4, 32, 4, 16, 4
	$.log "Training an aversion to the side-lines..."
	net.trainer.train trainingSet = [
		{ input: [ 0,0,0,0 ], output: actIdle }
		{ input: [ 1,0,0,0 ], output: actIdle }
		{ input: [ 0,1,0,0 ], output: actLeft }
		{ input: [ 0,0,1,0 ], output: actUp }
		{ input: [ 0,0,0,1 ], output: actRight }
	]
	sense: (world, frame) -> [
		+(@unit.y < 0),
		+(@unit.x > 52),
		+(@unit.y > 100),
		+(@unit.x < 1),
	]
	react: (world, frame) ->
		net.activate Float64Array.from @sense world, frame
	retrain: -> net.trainer.train trainingSet

class RushImpulse extends Impulse
	net = new synaptic.Architect.Liquid 8, 32, 4, 16, 4
	$.log "Training the desire to run the ball to the end-zone..."
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
	sense: (world, frame) ->
		@unit.getGrid frame, (obj) => obj.team? and obj.team isnt @unit.team
	react: (world, frame) ->
		net.activate Float64Array.from @sense world, frame
	retrain: -> net.trainer.train trainingSet

class BlockImpulse extends Impulse
	net = new synaptic.Architect.Liquid 8, 32, 4, 16, 4
	$.log "Training blocking..."
	net.trainer.train trainingSet = [
		{ input: [ 0,0,0,0,0,0,0,0 ], output: actUp }
		{ input: [ 1,0,0,0,0,0,0,0 ], output: actUp }
		{ input: [ 0,1,0,0,0,0,0,0 ], output: actUpLeft }
		{ input: [ 0,0,1,0,0,0,0,0 ], output: actLeft }
		{ input: [ 0,0,0,1,0,0,0,0 ], output: actDown }
		{ input: [ 0,0,0,0,1,0,0,0 ], output: actDown }
		{ input: [ 0,0,0,0,0,1,0,0 ], output: actRight }
		{ input: [ 0,0,0,0,0,0,1,0 ], output: actUpRight }
		{ input: [ 0,0,0,0,0,0,0,1 ], output: actUp }
	]
	sense: (world, frame) ->
		@unit.getGrid frame, (obj) =>
			obj.team? and obj.team isnt @unit.team and not obj.blocked
	react: (world, frame) ->
		net.activate Float64Array.from @sense world, frame
	retrain: -> net.trainer.train trainingSet

