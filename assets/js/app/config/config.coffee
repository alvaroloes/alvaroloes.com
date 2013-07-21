class window.Config
  # General sizes (in pixels)
  @solarSystemSize : 10
  @sunSize         : @solarSystemSize / 10
  @planetSize      : @solarSystemSize / 50

  # Orbits periods (in milliseconds)
  @baseOrbitPeriod           : 20000
  @personalOrbitPeriod       : 1.5 * @baseOrbitPeriod
  @reflexiveOrbitPeriod      : 2.0 * @baseOrbitPeriod
  @laborOrbitPeriod          : 4.1 * @baseOrbitPeriod
  @technologicalOrbitPeriod  : 5.9 * @baseOrbitPeriod

  # Orbits radius an trails sizes
  @baseOrbitRadius           : @solarSystemSize / 10
  @personalOrbitRadius       : 1.2 * @baseOrbitRadius + @planetSize / 2
  @reflexiveOrbitRadius      : 2.2 * @baseOrbitRadius + @planetSize / 2
  @laborOrbitRadius          : 3.5 * @baseOrbitRadius + @planetSize / 2
  @technologicalOrbitRadius  : 4.5 * @baseOrbitRadius + @planetSize / 2
  @trailWidth : @planetSize * 2

  # Colors
  @personalColor       : (a = 1)-> "rgba(251,218,147,#{a})"
  @reflexiveColor      : (a = 1)-> "rgba(211,235,190,#{a})"
  @laborColor          : (a = 1)-> "rgba(225,229,234,#{a})"
  @technologicalColor  : (a = 1)-> "rgba(225,223,225,#{a})"
