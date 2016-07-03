Measurements
------------

.. module:: gis

======================================== ========================================
SQL/MM                                   Lua
======================================== ========================================
:func:`ST.Area`                          :func:`Geometry.area`
:func:`ST.Length`                        :func:`Geometry.length`
:func:`ST.Distance`                      :func:`Geometry.distance`
:func:`ST.HausdorffDistance`             :func:`Geometry.hausdorffdistance`
                                         :func:`Geometry.hausdorff`
======================================== ========================================

.. method:: Geometry.area()

    :returns: the area of the surface
    :rtype: double

    Returns the area of the surface if it is a Polygon or MultiPolygon.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.10.2.

    .. code-block:: lua

        tarantool> nevada = gis.Polygon({{
            {-120.000000, 42.000000};
            {-114.000000, 42.000000};
            {-114.000000, 34.687427};
            {-120.000000, 39.000000};
            {-120.000000, 42.000000};
        }}, 4326)
        ---
        ...

        -- Use U.S. National Atlas Equal Area projection (meters)
        tarantool> nevada:transform(2163):area() * 1e-6
        ---
        - 293496.74070953 -- km^2
        ...

.. function:: ST.Area(g)

    This function is a SQL/MM-compatible alias for :func:`Geometry.area`.
    SQL-MM 3: 8.1.2, 9.5.3.


.. method:: Geometry.length()

    :returns: 2D length of the curve
    :rtype: number

    Returns the 2D Cartesian length of the geometry.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.6.2.

    .. code-block:: lua

        tarantool> lasvegas = gis.Point({-115.136389, 36.175}, 4326):transform(2770)
        ---
        ...

        tarantool> losangeles = gis.Point({-118.25, 34.05}, 4326):transform(2770)
        ---
        ...

        tarantool> gis.LineString({lasvegas, losangeles}, 2770):length()
        ---
        - 368942.77529796
        ...

.. function:: ST.Length(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.length`.
    SQL-MM 3: 7.1.2, 9.3.4.


.. method:: Geometry.distance(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: cartesian distance between two geometries in units of
              spatial reference system
    :rtype: number

    Returns the minimum cartesian distance between two geometries in units of
    spatial reference system.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.4.

    .. code-block:: lua

        tarantool> lasvegas = gis.Point({-115.136389, 36.175}, 4326):transform(2770)
        ---
        ...

        tarantool> losangeles = gis.Point({-118.25, 34.05}, 4326):transform(2770)
        ---
        ...

        tarantool> lasvegas:distance(losangeles)
        ---
        - 368942.77529796
        ...

.. function:: ST.Distance(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.distance`.
    SQL-MM 3: 5.1.23.

.. method:: Geometry.hausdorff(g2)
            Geometry.hausdorffdistance(g2)
            Geometry.hausdorff(g2, densityfrac)
            Geometry.hausdorffdistance(g2, densityfrac)

    :param g2: geometry
    :type  g2: geometry
    :param densityfrac: fraction of segment densification
    :type  densityfrac: double
    :returns: Hausdorff distance between two geometries
    :rtype: number

    Returns the Hausdorff distance between two geometries. Basically a measure
    of how similar or dissimilar 2 geometries are.

    When densifyFrac is specified, this function performs a segment
    densification before computing the discrete hausdorff distance.
    The densifyFrac parameter sets the fraction by which to densify each
    segment. Each segment will be split into a number of equal-length
    subsegments, whose fraction of the total length is closest to the given
    fraction.

    .. code-block:: lua

        tarantool> linestring = gis.LineString({ {0, 0}, {2, 0} }, 0)
        ---
        ...

        tarantool> multipoint = gis.MultiPoint({ {0, 1}, {1, 0}, {2, 1} }, 0)
        ---
        ...

        tarantool> linestring:hausdorff(multipoint)
        ---
        - 1
        ...

        tarantool> linestring2 = gis.LineString({ {0, 0}, {3, 0}, {0, 3} }, 0)
        ---
        ...

        tarantool> linestring:hausdorff(linestring2)
        ---
        - 3
        ...

.. function:: ST.HausdorffDistance(g1, g2)

    An alias for :func:`Geometry.hausdorff`
