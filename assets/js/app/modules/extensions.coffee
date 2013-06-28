# Returns a random element
Array::sample = ->
  @[Math.floor(Math.random() * this.length)]

# Treat the array as it was an interval defined by [ this[0] , this[1] ) and returns a
# number between limits
Array::sampleInterval = (integer = false)->
  ini = @[0]
  inc = Math.random() * (@[1] - @[0])
  if integer
    ini = Math.floor(ini)
    inc = Math.floor(inc)
  ini + inc

# Homogenize requestAnimationFrame function
window.requestAnimFrame = do ->
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  (callback)->
    window.setTimeout(callback, 1000 / 60)