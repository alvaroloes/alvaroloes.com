class window.Config
  # Planet shadow image rotation (pointing to the brighter face and assuming 0 deg is the positive X axis)
  @planetShadowAngle: 3 * Math.PI / 2

  # General sizes (in pixels)
  @solarSystemSize : 10
  @sunSize         : @solarSystemSize / 10
  @planetSize      : @solarSystemSize / 50

  # Rotation periods
  @baseSelfRotationPeriod           : 10000
  @sunSelfRotationPeriod            : 2.5 * @baseSelfRotationPeriod
  @personalSelfRotationPeriod       : 1.2 * @baseSelfRotationPeriod
  @reflexiveSelfRotationPeriod      : 1.5 * @baseSelfRotationPeriod
  @laborSelfRotationPeriod          : 2 * @baseSelfRotationPeriod
  @techSelfRotationPeriod           : 0.5 * @baseSelfRotationPeriod

  # Orbits periods (in milliseconds)
  @baseOrbitPeriod           : 20000
  @personalOrbitPeriod       : 1.5 * @baseOrbitPeriod
  @reflexiveOrbitPeriod      : 2.0 * @baseOrbitPeriod
  @laborOrbitPeriod          : 4.1 * @baseOrbitPeriod
  @techOrbitPeriod           : 5.9 * @baseOrbitPeriod

  # Orbits radius an trails sizes
  @baseOrbitRadius           : @solarSystemSize / 10
  @personalOrbitRadius       : 1.2 * @baseOrbitRadius + @planetSize / 2
  @reflexiveOrbitRadius      : 2.2 * @baseOrbitRadius + @planetSize / 2
  @laborOrbitRadius          : 3.5 * @baseOrbitRadius + @planetSize / 2
  @techOrbitRadius           : 4.5 * @baseOrbitRadius + @planetSize / 2
  @trailWidth : @planetSize * 2

  # Colors
  @personalColor       : (a = 1)-> "rgba(251,218,147,#{a})"
  @reflexiveColor      : (a = 1)-> "rgba(211,235,190,#{a})"
  @laborColor          : (a = 1)-> "rgba(225,229,234,#{a})"
  @techColor           : (a = 1)-> "rgba(225,223,225,#{a})"

  @wgSizeFactor: 50
  @wgDistanceFactor: 200
