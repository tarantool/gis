Spatial Reference Systems
=========================

The ``spatial_ref_sys`` table is an OGC compliant database table that lists over
5000 known spatial reference systems and details needed to transform/reproject
between them.

Although the ``spatial_ref_sys`` table contains over 5000 of the more commonly
used spatial reference system definitions that can be handled by the PROJ4
library, it does not contain all known to man and you can even define your
own custom projection if you are familiar with proj4 constructs. Keep in mind
that most spatial reference systems are regional and have no meaning when used
outside of the bounds they were intended for. Please read the great
`"Choosing the Right Map Projection" <https://source.opennews.org/en-US/learning/choosing-right-map-projection/>`_
article if you are newbie.

An excellent resource for finding spatial reference systems not defined in
the core set is http://spatialreference.org/

Some of the more commonly used spatial reference systems are:

* 4326 - WGS84 Long Lat
* 4328 - WGS84 GeoCentered (3D)
* 4269 - NAD 83 Long Lat
* 3395 - WGS 84 World Mercator
* 2163 - US National Atlas Equal Area,
* WGS84 UTM zones are one of the most ideal for measurement, but only cover
  6-degree regions.

Various US state plane spatial reference systems (meter or feet based) -
usually one or 2 exists per US state. Most of the meter ones are in the core
set, but many of the feet based ones or ESRI created ones you will need to pull
from http://spatialreference.org/.

.. figure:: srs.jpg
   :alt: The USA four ways
