#GPS Navigation: Finding POIs along a Route

2010-11-01

<!--- tags: gps -->

In a GPS navigation system, it is often interesting to find **points of interests** (POI) along a **navigation route**. When POIs are properly [geocoded](http://en.wikipedia.org/wiki/Geocoding), they will contain only one verified reference street segment (branch). When POI geocoding from coordinates is done automatically (either pre-processed or at run-time), it may happen that more than a branch is (and should be) associated with a POI.

The easiest approach to search for POIs along a route (this process is dynamic, depending on the route) is to scan a corridor around the route and to consider a found POI only if its nearest branch belongs to the route. This works ok for some cases, but there are a range of situations where this is not enough, especially for street crossings. Consider the case, illustrated in the figure below:

![](blog/2010/nav/pois-along-a-route.png)

When searching along route with a narrow corridor B1, we find POIs P2 and P4. But in this case we miss P1. P1 can be important as POI of interest, because the route is its nearest segment.

If we enlarge search corridor and use B2, then we indeed include P1, but we include also P3. In this case the nearest branch of P3 does not belong to route, so P3 would be a wrong result.

This problem can be solved in many cases, by doing a secondary search for the nearest branch:

* To avoid missing P1, we always search in a relative wide corridor B2 along the route.
* We look then for the nearest branch associated with each found POI. We consider the POI only when its nearest branch belong to route.
This method will find P1 and P2 as being along the route, but not P3 as expected.

P4 case is still problematic. P4 has the same distance from the route and from a branch not belonging to the route. If we use the nearest branch approach we may get by chance either the branch belonging to route, or the other one. Because we are not sure for P4, we should include it in the result.

To remedy this case, we modify step (b) above as follows:

* (b.1)	For each found POI of interest, we do a secondary search for all its nearest branches in zone B2xB2. We order the found branches by distance.
* (b.2)	To find whether the POI is interesting for the route, we see whether any of the branches with (same) minimum distance belongs to the route (to the part where we are).

Because of error margin  when considering distances, b.2 step needs to be not that strict. A better method is to check b.2 and the next branches that are no longer than a small threshold (let say 10 meters) from the minimum branch distance found.

This extended heuristic method gives very accurate results for POIs that really should be considered to be of interest when driving a given known route. When combined with other data (such as POI direction information when available), the method gives incredibly accurate results for POI warners based on coordinate POI data.
<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2010/2010-11-02-Speed-Based-Volume-Adaption-for-Navigation.md'>Speed Based Volume Adaption for Navigation</a> <a rel='next' id='fnext' href='#blog/2010/2010-10-10-CSharp-ListView-VirtualMode-Selection.md'>CSharp ListView VirtualMode Selection</a></ins>
