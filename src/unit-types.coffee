

class OffenseUnit extends Unit

class DefenseUnit extends Unit

class Lineman extends DefenseUnit
	constructor: (opts) ->
		opts.spd = clamp $.random.gaussian(.5, .1), 0.4, 0.6
		super opts
		@brain = new Brain @, ChaseImpulse(football)

class Linebacker extends DefenseUnit
	constructor: (opts) ->
		opts.spd = clamp $.random.gaussian(.7, .1), 0.6, 0.8
		super opts
		@brain = new Brain @, ChaseImpulse(football)

class Cornerback extends DefenseUnit
	constructor: (opts) ->
		opts.spd = clamp $.random.gaussian(.65, .1), 0.6, .8
		super opts
		@brain = new Brain @, ChaseImpulse(player)

class OLineman extends OffenseUnit
	constructor: (opts) ->
		super opts
		@brain = new Brain @, BlockImpulse
