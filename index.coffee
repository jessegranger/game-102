
{ round, pow, sin, sign, atan2, min, max, floor, ceil, abs, sqrt, PI } = Math

magn = (x,y) -> sqrt((x*x)+(y*y))

#include "brain.coffee"

b = new Brain { getGrid: -> new Float64Array(8) }, RushImpulse, BorderImpulse

b.react {}, {}

return

$.global.deg2rad = (d) -> d*2*PI/180
$.global.rad2deg = (r) -> (r*180)/(2*PI)

clamp = (n, a, b) -> max a, min b, n

field = {
	width: 53.33
	length: 120
	endzone: 10
	lefthash: 22
	righthash: 30
	hashwidth: 1
}

W = $.global.innerWidth
H = W * (field.length / field.width)

pixelsPerYard = H / field.length
yardsPerPixel = 1 / pixelsPerYard
yards = (n) -> n * pixelsPerYard
scrollToYardline = (y) -> $.global.scrollTo 0, yards(y + field.endzone) - ($.global.innerHeight/2)
$(document).ready -> $.delay 100, -> scrollToYardline 75

$("body")
	.css(
		margin: 0
		padding: 0
		textAlign: "left"
	)
	.html """
		<canvas id=terrain width=#{W} height=#{H}></canvas>
		<canvas id=viewport width=#{W} height=#{$.global.innerHeight}></canvas>
	"""

# idea:
# draw helmets and shoulders like before
# use a colored circle to show lighting
# placed and sized dynamically, so it tracks and pulses
# opening sequence: players moving on the field, with photo flashes


terrainCanvas = $("canvas#terrain").css
	position: "absolute"
	left: "0px"
	top: "0px"
terrainContext = terrainCanvas.first().getContext '2d'
terrainContext.translate -0.5, -0.5

viewCanvas = $("canvas#viewport").css
	position: "fixed"
	top: "0px"
	left: "0px"
	background: "transparent"
viewContext = viewCanvas.first().getContext '2d'
viewContext.translate -0.5, -0.5

Object.assign $.global, { terrainContext, viewContext }

Object.assign viewContext.__proto__.constructor.prototype, {
	clear: ->
		@clearRect 0, 0, @canvas.width, @canvas.height
		@
	circle: (x, y, r) ->
		@arc x, y, r, 0, 2*PI
		@
	strokeCircle: (x, y, r, w, c) ->
		@moveTo x, y
		@beginPath()
		@arc x, y, r, 0, 2*PI
		@lineWidth = w
		@strokeStyle = c
		@stroke()
		@closePath()
		@
	fillCircle: (x, y, r, c) ->
		@beginPath()
		@moveTo(x, y)
		@arc x, y, r, 0, 2*PI
		@fillStyle = c
		@fill()
		@closePath()
		@
	fillRect: (x, y, w, h, c) ->
		@rect x, y, w, h
		@fillStyle = c
		@fill()
		@
	strokeRect: (x, y, w, h, ww, c) ->
		@lineWidth = ww
		@strokeStyle = c
		@rect x, y, w, h
		@stroke()
		@
	alignTextAt: (x, y, align, text) ->
		m = @measureText(text)
		@fillText text, (switch align
			when "left" then x
			when "right" then x - m.width
			when "center" then x - (m.width/2)
		), y
		@
	strokeLine: (x1, y1, x2, y2, w, c) ->
		@strokeStyle = c
		@lineWidth = w
		@moveTo x1, y1
		@lineTo x2, y2
		@stroke()
		@
}


do drawTerrain = (context = terrainContext) ->
	$.log "Drawing Terrain..."
	context.fillRect 0, 0, W, H, 'green'
	context.strokeRect 0, 0, W, yards(field.endzone), 7, 'white'
	context.strokeRect 0, yards(field.length - field.endzone), W, yards(field.endzone), 7, 'white'

	halfYard = yards(.3)

	# Draw each 5-yard line fully
	context.beginPath()
	for yard_line in [5..95] by 5
		y = yards (yard_line + field.endzone)
		context.moveTo 0, y
		context.lineTo W, y
		context.moveTo yards(23), y-halfYard
		context.lineTo yards(23), y+halfYard
		context.moveTo yards(30), y-halfYard
		context.lineTo yards(30), y+halfYard
	context.closePath()
	context.lineWidth = 3
	context.strokeStyle = 'white'
	context.stroke()

	$.log "Drawing yard numbers..."
	context.font = "#{floor yards 1.4}px sans-serif"
	context.fillStyle = "white"
	right_arrow = $.HTML.parse("<p>&#x22b3;</p>").innerText
	left_arrow = $.HTML.parse("<p>&#x22b2;</p>").innerText
	for yard_line in [10..90] by 10
		y = yards (yard_line + field.endzone)
		s = switch
			when yard_line is 90
				y = y - 19
				(100 - yard_line) + right_arrow
			when yard_line > 50
				y = y - 21
				(100 - yard_line) + right_arrow
			when yard_line is 10
				y = y - 50
				left_arrow + yard_line
			when yard_line < 50
				y = y - 53
				left_arrow + yard_line
			when yard_line is 50
				y = y - 52
				left_arrow + yard_line + right_arrow
		s = s.split('').join(" ")
		context.save()
		context.translate yards(field.width/4)-yards(.7), y
		context.rotate PI/2
		context.alignTextAt 0, 0, "left", s
		context.translate 0, -yards(field.width/2)
		context.alignTextAt 0, 0, "left", s
		context.restore()
	
	$.log "Drawing hash marks..."
	context.beginPath()
	context.lineWidth = 2
	context.strokeStyle = 'white'
	for yard_line in [1..99] by 1
		continue if yard_line % 10 == 0
		y = yards (yard_line + field.endzone)
		context.moveTo 5, y
		context.lineTo yards(1), y
		context.moveTo yards(field.lefthash), y
		context.lineTo yards(field.lefthash + field.hashwidth), y
		context.moveTo yards(field.righthash), y
		context.lineTo yards(field.righthash + field.hashwidth), y
		context.moveTo yards(field.width - field.hashwidth), y
		context.lineTo W - 5, y
	context.closePath()
	context.stroke()

	$.log "Drawing end zone text..."

$.log "Constructing viewport..."
class Viewport
	@canvas = viewCanvas
	@context = viewContext
	$.defineProperty Viewport, 'x', { get: -> $.global.scrollX }
	$.defineProperty Viewport, 'y', { get: -> $.global.scrollY }
	$.defineProperty Viewport, 'w', { get: -> $.global.innerWidth }
	$.defineProperty Viewport, 'h', { get: -> $.global.innerHeight }
	$.defineProperty Viewport, 'cx', { get: -> $.global.innerWidth / 2 }
	$.defineProperty Viewport, 'cy', { get: -> $.global.innerHeight / 2 }
	@contains: (wx, wy) -> # inputs in world-coordinates
		true

head_size = yards(.4)
shoulder_size = yards(.33)
hand_size = head_size*.5
foot_size = head_size*.4

drawWalking = (unit, context) ->
	h = head_size
	walk_cycle = sin(unit.elapsed/110)
	walk_magn = sqrt magn(unit.vx, unit.vy)
	reach = [
		-yards(walk_cycle * walk_magn)
		yards(walk_cycle * walk_magn)
	]
	if reach[0] or reach[1]
		context.beginPath()
		context.fillStyle = unit.skin
		reach[0] and context.circle -h, -reach[0], hand_size # left hand
		reach[1] and context.circle h, -reach[1], hand_size # right hand
		context.fill()
		context.closePath()

		context.beginPath()
		context.fillStyle = 'black'
		# reverse and shrink the h and -h values here so feet are offset from and inside of the hands
		reach[0] and context.circle h/2, -reach[0], foot_size
		reach[1] and context.circle -h/2, -reach[1], foot_size
		context.fill()
		context.closePath()

drawBlocking = (unit, context) ->
	h = head_size
	context.beginPath()
	context.fillStyle = unit.skin
	context.circle -h, -yards(.45), hand_size
	context.circle h, -yards(.45), hand_size
	context.fill()
	context.closePath()
	f = h*.9
	context.beginPath()
	context.fillStyle = 'black'
	context.circle -f, yards(.35), foot_size
	context.circle f, yards(.35), foot_size
	context.fill()
	context.closePath()

projectYardsToScreen = (x, y) -> [
	(x * pixelsPerYard) - Viewport.x
	((y + field.endzone) * pixelsPerYard) - Viewport.y
]


drawUnit = (unit, context = viewContext) ->
	[x, y] = projectYardsToScreen(unit.x, unit.y)
	# $.log "x = (#{unit.x} * #{pixelsPerYard}) - #{Viewport.x} = #{x}"
	# $.log "y = ((#{unit.y} + #{field.endzone}) * #{pixelsPerYard}) - #{Viewport.y} = #{y}"
	if 0 <= x <= Viewport.w and 0 <= y <= Viewport.h
		context.save()
		context.translate x, y
		context.rotate unit.r
		str_size_bonus = unit.str * yards(.04)
		s = shoulder_size
		h = head_size

		switch unit.mode
			when "walking" then drawWalking unit, context
			when "blocking" then drawBlocking unit, context

		context.beginPath()
		context.fillStyle = unit.team.colors[1]
		context.circle -h, 0, s # left shoulder
		context.circle h, 0, s # right shoulder
		context.fill()
		context.closePath()

		context.beginPath()
		context.fillStyle = unit.team.colors[0]
		context.strokeStyle = 'black'
		context.circle 0, 0, h # head
		context.fill()
		context.stroke()
		context.closePath()

		context.beginPath()
		context.lineWidth = 2
		context.strokeStyle = 'white'
		context.moveTo -h/2,-h
		context.lineTo h/2,-h
		context.stroke()
		context.closePath()

		context.restore()

teamOne = {
	colors: [
	 'rgba(128,0,0,1)'
	 'rgba(150,0,0,1)'
	]
}
teamTwo = {
	colors: [
		'rgba(50,50,170,1)'
		'rgba(50,50,200,1)'
	]
}
skinShade = [
	lightSkin = 'rgba(190, 170, 170, 1)'
	'rgba(170, 130, 130, 1)'
	'rgba(150, 100, 100, 1)'
	'rgba(130, 90, 90, 1)'
	darkSkin = 'rgba(110, 70, 70, 1)'
]

paused = true

openingTitles = {
	elapsed: 0
	fadeIn: (ms) ->
		Math.min(1.0, (@frames[0]?[2] ? 0) / ms)
	tick: (dt) ->
		if frame = @frames[0]
			# frame.elapsed ?= 0
			# frame.elapsed += dt
			frame[2] -= dt
			viewContext.fillRect 0, 0, W, H, 'black'
			if frame[2] <= 0
				@frames.shift()
			else
				viewContext.font = "#{floor yards 2}px sans-serif"
				frame.width ?= viewContext.measureText(frame[0]).width
				viewContext.fillStyle = "rgba(255,255,255,#{@fadeIn frame[1]})"
				viewContext.fillText frame[0], Viewport.cx - (frame.width/2), Viewport.cy
			true
		else
			false
	frames: [
		[ "Hold v to play", 200, 1800 ]
	]
}

class Input
	keysDown = {}
	onceDown = {}
	onceUp = {}
	onDown = {}
	onUp = {}
	aliases = {}
	@isKeyDown = (keyName) -> keysDown[keyName] ? false
	@setKeyDown = (keyName, v) -> keysDown[keyName] = v
	$(document.body).bind "keydown", (evt) ->
		n = $.keyName evt.keyCode
		for k in aliases[n] ? [n]
			keysDown[k] = true
			if onceDown[k]?.length > 0
				onceDown[k].call(k, evt)
				onceDown[k].clear()
				evt.preventAll()
			else if onDown[k]?.length > 0
				onDown[k].call k, evt
				evt.preventAll()
		null
	$(document.body).bind "keyup", (evt) ->
		n = $.keyName evt.keyCode
		for k in aliases[n] ? [n]
			keysDown[k] = false
			if onceUp[k]?.length > 0
				onceUp[k].call k, evt
				onceUp.clear()
			else if onUp[k]?.length > 0
				onUp[k].call k, evt
		null
	$(document.body).bind "keypress", (evt) -> evt.preventDefault()

	@once =        (keyName, cb) -> (onceDown[keyName] or= $ []).push cb
	@onceRelease = (keyName, cb) -> (onceUp[keyName] or= $ []).push cb
	@bind =        (keyName, cb) -> (onDown[keyName] or= $ []).push cb
	@onRelease =   (keyName, cb) -> (onUp[keyName] or= $ []).push cb
	@alias =       (from, to)    -> (aliases[from] or= $ [from]).push to

world = {
	friction: .005
	velocity: { max: 1, min: .0001 }
	units: $ []
	tick: (dt, frame) ->
		for unit in world.units
			unit.tick(dt, frame)
		viewContext.clear()
		for unit in world.units when Viewport.contains(unit.x, unit.y)
			unit.drawShadow?(viewContext, frame)
		for unit in world.units when Viewport.contains(unit.x, unit.y)
			unit.draw(viewContext, frame)
}

zero2d = $(0,0)
getInputForce = (unit) ->
	dx = Input.isKeyDown("MoveRight") - Input.isKeyDown("MoveLeft")
	dy = Input.isKeyDown("MoveDown") - Input.isKeyDown("MoveUp")
	return if dx isnt 0 or dy isnt 0
		$(dx,dy).normalize().scale(unit.spd/750)
	else zero2d

addForceToVelocity = (u, dx, dy, dt) ->
	u.vx += dx * dt
	u.vy += dy * dt
	_max = world.velocity.max
	u.vx = clamp u.vx, -_max, _max 
	u.vy = clamp u.vy, -_max, _max
	# apply friction
	u.vx *= _f = pow(1 - world.friction,dt)
	u.vy *= _f
	abs(u.vx) < (_min = world.velocity.min) and u.vx = 0
	abs(u.vy) < _min and u.vy = 0

turnToFace = (u, x, y) ->
	if x isnt 0 or y isnt 0
		desired = atan2 x, -y
		dr = desired - u.r
		if abs(dr) > PI # turn the shortest angle
			dr = (2*PI) - (sign dr) * dr
		turn_spd = .2 * u.spd
		if abs(dr) > turn_spd
			dr = turn_spd * sign(dr)
		u.r += dr

class Unit
	constructor: (opts) ->
		$.extend @, {
			x: field.width/2, y: 50
			r: 0 # in radians
			str: 0.5 # strength, 0 - 1.0
			spd: 0.5
			team: teamOne
			skin: $.random.element(skinShade)
			vx: 0, vy: 0 # velocity
			input: false
			elapsed: 0
			mode: 'walking'
		}, opts
		@spd = clamp @spd, 0.0, 1.0
		@str = clamp @str, 0.0, 1.0
		@x = clamp @x, -10.0, field.width+10
		@y = clamp @y, -10.0, field.length+10
	tick: (dt, frame) ->
		turnToFace @, @vx, @vy
		@x = clamp @x + @vx, -1.0, field.width+1
		@y = clamp @y + @vy, -1.0, field.length+1
		@elapsed += dt
	draw: (context) ->
		drawUnit @, context
	drawShadow: (context) ->
		context.beginPath()
		context.fillStyle = 'rgba(0,0,0,.5)'
		context.circle yards(@x), yards(@y), yards(1), 0, @*PI
		context.fill()
		context.closePath()
	getGrid: (frame, filter) ->
		ret = $ new Array 8
		# 8 cells with values 0-1 (eventually)
		# each cell corresponds to a 45 degree arc
		# 0 means no (or far) target in the area of the arc
		# 1 means target adjacent
		# roughly, (1 - normalized distance to closest target)

		# first, put in the array the min distance for each bucket
		for unit in world.units when filter(unit)
			dx = unit.x - @x
			dy = unit.y - @y
			continue if isNaN(dx) or isNaN(dy)
			r = PI + atan2 dx, dy
			r -= 2*PI if r >= 2*PI
			r += 2*PI if r < 0
			bin = floor (r * 4/PI)
			dist_sq = frame?.dist_sq.get(@).get(unit) ? ( (dx*dx) + (dy*dy) )
			ret[bin] = min dist_sq, (ret[bin] ? Infinity)
			# $.log "Checking unit", { dx, dy, r, bin, ret_bin: ret[bin] }

		# Scale everything by 150 so that even someone 100 yards away is still .3 interesting (1 - 100/150)
		# This is to help keep close units more significant and to expand the attention horizon
		# Without this re-scaling the attention horizon is 10-12 yards
		for v,i in ret
			ret[i] = clamp 1 - ((v ? 150)/150), 0, 1 
		ret
	
	getNearest: (frame) ->
		o = undefined
		n = Infinity
		for [k, v] from frame.dist_sq.get(@).entries()
			if v < n
				v = n
				o = k
		return [o, n]



class Football
	constructor: (opts) ->
		$.extend @, {
			x: field.width/2, y: 50
			r: 0
			radius: yards(.4)
			holder: null
			target: null
			elapsed: 0
			vx: 0, vy: 0, vr: 0
		}, opts
	tick: (dt, frame) ->
		@elapsed += dt
		@vx *= _f = pow (1 - world.friction), dt
		@vy *= _f
		@vr *= _f

		if not @holder
			closest = Infinity
			closest_unit = undefined
			for unit in world.units when $.isType(Unit, unit)
				if (d = frame.dist_sq.get(@).get(unit)) < closest
					closest = d
					closest_unit = unit
			if closest < .75
				$.log "Ball picked up!"
				@holder = closest_unit # TODO: fumble here

		if @holder
			@x = @holder.x
			@y = @holder.y
			@r = @holder.r
		else
			if @target
				dx = (@target.x - @x)
				dy = (@target.y - @y)
				m = magn dx, dy
				@vx = (dx/m) * .03
				@vy = (dy/m) * .03
			@x += @vx * dt
			@y += @vy * dt
			@r += @vr * dt

	hikeTo: (@target) ->
		$.log "hiking to", @target
		@vr = .5

	draw: (context) ->
		[x, y] = projectYardsToScreen(@x, @y)
		context.save()
		context.translate x, y
		if @r isnt 0
			context.rotate @r
		context.arc 0, 0, @radius, 0, 2*PI
		context.fillStyle = 'rgba(130, 60, 60, 1)'
		context.fill()
		context.closePath()

		left = -@radius/4
		right = @radius/4
		top = -@radius/2
		bottom = @radius/2
		upper = -@radius/3
		lower = @radius/3
		context.beginPath()
		context.strokeStyle = 'white'
		context.lineWidth = 1
		context.moveTo 0, top
		context.lineTo 0, bottom
		context.moveTo left, upper
		context.lineTo right, upper
		context.moveTo left, 0
		context.lineTo right, 0
		context.moveTo left, lower
		context.lineTo right, lower
		context.stroke()
		context.closePath()

		context.restore()
	

# ActiveUnit is the single player controlled by the human at the keyboard
class ActiveUnit extends Unit
	constructor: (opts) ->
		super opts
		@brain = new Brain @, brains.runWithBall
	tick: (dt, frame) ->
		nearest = @getNearest(frame)
		if nearest[1] < .5
			$.log "Collision:", nearest
			return pause()

		# if we press the AI key, let it control our movements
		if Input.isKeyDown("UseAI")

			state = @brain.perceive(frame)
			[up, right, down, left] = @brain.react(state)

			Input.setKeyDown("MoveUp", up)
			Input.setKeyDown("MoveRight", right)
			Input.setKeyDown("MoveDown", down)
			Input.setKeyDown("MoveLeft", left)

		# keys keep adding speed the longer you hold them, up to a point
		addForceToVelocity @, getInputForce(@)..., dt

		super dt

	draw: (context) ->
		scrollToYardline @y
		super context

class AIUnit extends Unit
	@tick_per_ms = 100
	constructor: (opts) ->
		super opts
		@brain = new Brain @, brains.idle
		@ai_last_tick = 0
	tick: (dt, frame) ->
		if Input.isKeyDown("UseAI")
			if (ai_dt = @elapsed - @ai_last_tick) > AIUnit.tick_per_ms
				@ai_last_tick = @elapsed
				@ai_tick ai_dt, frame
		super dt
	ai_tick: (dt, frame) ->
		[up, right, down, left] = @brain.react percept = @brain.perceive(frame)
		$.log "percept:", percept
		dx = right - left
		dy = down - up
		if dx isnt 0 or dy isnt 0
			force = $(dx,dy).normalize().scale(@spd/750)
			addForceToVelocity @, force[0], force[1], dt


world.units.push $.global.football = new Football({ x: 26, y: 75 })
world.units.push $.global.player = new ActiveUnit {
	x: 26, y: 80
	spd: 0.7
}

class OffenseUnit extends AIUnit
class DefenseUnit extends AIUnit

class Lineman extends DefenseUnit
	constructor: (opts) ->
		opts.spd = clamp $.random.gaussian(.5, .1), 0.4, 0.7
		super opts

class Linebacker extends DefenseUnit
	constructor: (opts) ->
		opts.spd = clamp $.random.gaussian(.85, .1), 0.7, 0.95
		super opts

class Cornerback extends DefenseUnit
	constructor: (opts) ->
		opts.spd = clamp $.random.gaussian(.9, .07), 0.8, 1.0
		super opts

deployFormation = (cx, cy, formation, opts={}) ->
	for {type, loc} in formation
		for [x,y,r,stance] in loc
			world.units.push new type $.extend {}, opts, {
				x: cx+x, y: cy+y, r: r, stance: stance
			}
	null

deployFormation 26, 75, [
	{
		type: Lineman,
		loc: [
			[ -3, -1, PI, 'low' ]
			[ -1, -1, PI, 'low' ]
			[  1, -1, PI, 'low' ]
			[  3, -1, PI, 'low' ]
		]
	}
	{
		type: Linebacker,
		loc: [
			[  0, -6, PI, 'mid' ]
			[ -3, -5, PI, 'mid' ]
			[  3, -5, PI, 'mid' ]
		]
	}
	{
		type: Cornerback,
		loc: [
			[ -12, -3, PI, 'high' ]
			[ 12, -3, PI, 'high' ]
			[ -6, -20, PI, 'high' ]
			[ 6, -20, PI, 'high' ]
		]
	}
], { team: teamTwo }


world.units.push fpsView = {
	tick: (dt, frame) -> @fps = 1000 / dt
	draw: (context, frame) ->
		context.fillStyle = 'black'
		context.font = "#{floor yards .5}px sans-serif"
		context.fillText "FPS: #{@fps.toFixed 2}", 10, 14
		context.fillText "Percept: #{ player.brain.perceive(frame).map (f) -> f.toFixed(2) }", 10, 28
}


last_tick = $.now
tick = ->
	last_tick += dt = $.now - last_tick

	# pre-compute the pair-wise distances,
	# so we only have to do this once per frame
	frame = {
		dist_sq: dist_sq = new Map()
	}
	for obj in world.units
		dist_sq.set obj, new Map()
		for obj2 in world.units
			continue if dist_sq.get(obj)?.get(obj2)?
			unless dist_sq.has obj2
				dist_sq.set obj2, new Map()
			if obj is obj2
				dist_sq.get(obj).set obj2, 0
				dist_sq.get(obj2).set obj, 0
				continue
			dx = obj2.x - obj.x
			dy = obj2.y - obj.y
			d = (dx*dx) + (dy*dy)
			dist_sq.get(obj).set obj2, d
			dist_sq.get(obj2).set obj, d
	openingTitles.tick(dt) \
		or world.tick(dt, frame)
	paused or requestAnimationFrame tick
	true

pause = ->
	$.log "Paused"
	paused = true
do resume = -> if paused
	$.log "Resumed"
	last_tick = $.now
	paused = false
	tick()
Input.bind "Space", -> resume() or pause()
Input.alias "w", "MoveUp"
Input.alias "a", "MoveLeft"
Input.alias "s", "MoveDown"
Input.alias "d", "MoveRight"
Input.alias "v", "UseAI"
Input.once "v", ->
	football.hikeTo player
Input.onRelease "v", ->
	Input.setKeyDown "MoveUp", false
	Input.setKeyDown "MoveRight", false
	Input.setKeyDown "MoveDown", false
	Input.setKeyDown "MoveLeft", false
	for unit in world.units when unit.team is teamTwo
		unit.vx = unit.vy = 0
	null

Input.setKeyDown "UseAI", true

