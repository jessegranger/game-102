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
