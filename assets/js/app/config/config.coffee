class window.Config
  # General sizes (in pixels)
  @solarSystemSize : 1000
  @sunSize         : @solarSystemSize / 10
  @planetSize      : @solarSystemSize / 50

  # Orbits periods (in milliseconds)
  @baseOrbitPeriod           : 40000
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
