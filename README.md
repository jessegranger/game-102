# game-102

This Game #102 loads an (American) Football field, with a simple set of red (offense) and blue (defense) players.

Each unit's brain is a list of Impulses.

Each Impulse is a simple neural net (a Liquid State Machine), that has been drilled on one concept, e.g.

  * "seek the ball"
  * "avoid the sidelines"
  * "block somebody"
  * "avoid opponents"
  * "get positive yards"

In each time-slice, each Impulse calls `sense()` then `react()`, and the Brain combines those reactions.

So the running back might run a brain that contains: "avoid sidelines", "get positive yards", "avoid opponents"

The offensive line is only listening to: "block somebody"

While the defense is all just using: "seek the ball"

All play is driven by the choices of the neural nets.

The A.I.
--------

Liquid State Machines are easy-to-train neural nets that have a large, randomly-connected and re-entrant, hidden layer. Because it is randomly connected, it can model a large number of functions, and because it is re-entrant, it can see and learn patterns over time.

Because you are only training the output layer to read patterns from the hidden layer the training is faster, but like all neural nets you need a lot of data to learn to make complex decisions based on high-dimension inputs (like images, or the game state, etc).

To avoid this problem and train nets quickly, the decision-making here is split up into *Impulses*.

Each Impulse calls `sense(world, frame)` to gather data about relevant things in the world. This returns an array like: `[ .75 .25 .00 .00 .02 .00 .00 .66 ]`. (see: Unit.getGrid in src/index.coffee).

This return value is a description of the 8 radial directions around the unit.


    +---+---+
    |\ 0|7 /|
    |1\ | /6|
    +---|---+
    |2 /|\ 5|
    | /3|4\ |
    +---+---+

So, if `precept = sense(world, frame)`, then the value in `percept[0]` refers to something that is North-North-West of the sensing unit.

In most cases, you can think of the `percept` as the output of a range finder that can be set to look for certain things (opponents, the ball, the sidelines, etc), but can only describe it's output in this normalized octant resolution.


