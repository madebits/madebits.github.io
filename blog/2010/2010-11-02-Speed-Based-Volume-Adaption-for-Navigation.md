#GPS Navigation: Speed-Based Volume Adaption for Navigation

2010-11-02

<!--- tags: gps -->

Volume level that a navigation device uses to play advice sound can be speed depended - raising the volume the faster user drives. A simple way of realizing this is to build a map {speed, volume} and define it for ranges of speed. Perception of volume is subjective and different to every user. This simple way has the drawback that for some users volume is either too low or too high.

A better way is to dynamically adapt volume-speed relation based not only on speed, but also on the user selected volume level. In the simplest case, volume-speed relation is linear: `IdealAutoVolume = a * speed + b`, but any relation can be used similarly.

A given time `T1`, the user sets device volume `V1`. At this moment we find the difference between `V1` and the ideal volume for the current speed given by `IdealAutoVolume` relation. Difference `DV = IdealAutoVolume - V1`, defines the "subjective" difference between the preferred volume and user perceived volume. `DV` is then used in all times `T2 > T1` to adjust the ideal speed dependent volume. Real automatic volume is then: `AutoVolume = IdealAutoVolume + DV`.

![](blog/2010/nav/speed-volume.png)

An additional restriction can be defined as a delta value around user volume - so that real auto volume is always at some range around user volume `V1`. Delta threshold ensures that not matter how big or small speed becomes, real volume is not very much different from user set volume, and protects from having extreme volume values.

<ins class='nfooter'><a id='fprev' href='#blog/2011/2011-10-11-WCF-Authentication-Cookies.md'>WCF Authentication Cookies</a> <a id='fnext' href='#blog/2010/2010-11-01-Finding-POIs-along-a-Route.md'>Finding POIs along a Route</a></ins>
