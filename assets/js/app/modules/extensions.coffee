# Returns a random element
Array::sample ?= ->
  @[Math.floor(Math.random() * this.length)]

# Treat the array as it was an interval defined by [ this[0] , this[1] ) and returns a
# number between limits
Array::sampleInterval ?= (integer = false)->
  ini = @[0]
  inc = Math.random() * (@[1] - @[0])
  if integer
    ini = Math.floor(ini)
    inc = Math.floor(inc)
  ini + inc

Array::shuffle ?= ->
  # Algorithm taken from: https://coffeescript-cookbook.github.io/chapters/arrays/shuffling-array-elements
  i = @.length
  while --i > 0
    j = ~~(Math.random() * (i + 1)) # ~~ is a common optimization for Math.floor
    t = @[j]
    @[j] = @[i]
    @[i] = t
  this

# Homogenize requestAnimationFrame function
window.requestAnimFrame = do ->
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  (callback)->
    window.setTimeout(callback, 1000 / 60)

# Amazing method to force a reflow (useful when assigning classes and want the results immediately)
window.reflow = ->
  $(window).height()