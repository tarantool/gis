Relationships
-------------

.. module:: gis

======================================== ========================================
SQL/MM                                   Lua
======================================== ========================================
:func:`ST.Equals`                        :func:`Geometry.equals`
:func:`ST.Disjoint`                      :func:`Geometry.disjoint`
:func:`ST.Intersects`                    :func:`Geometry.intersects`
:func:`ST.Touches`                       :func:`Geometry.touches`
:func:`ST.Crosses`                       :func:`Geometry.crosses`
:func:`ST.Within`                        :func:`Geometry.within`
:func:`ST.Contains`                      :func:`Geometry.contains`
:func:`ST.Overlaps`                      :func:`Geometry.overlaps`
:func:`ST.Covers`                        :func:`Geometry.covers`
:func:`ST.CoveredBy`                     :func:`Geometry.coveredby`
======================================== ========================================

.. method:: Geometry.equals(g2)
            Geometry.equals(g2, tolerance)

    :param g2: geometry
    :type  g2: geometry
    :param tolerance: tolerance
    :param tolerance: double
    :returns: true if the given geometries represent the same geometry
    :rtype: boolean

    Returns true if the given Geometries are "spatially equal".
    Note by spatially equal we mean g1:within(g2) and g2:within(g1) and also
    mean ordering of points can be different but represent the same geometry
    structure.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.3.

    .. code-block:: lua

        tarantool> gis.LineString({{0, 0}, {2, 2}}, 0):equals(gis.LineString({{2, 2}, {0, 0}}, 0))
        ---
        - true
        ...

        tarantool> gis.LineString({{0, 0}, {2, 2}}, 0):equals(gis.LineString({{2, 5}, {0, 0}}, 0))
        ---
        - false
        ...

        tarantool> gis.LineString({{0, 0}, {2, 2}}, 0):equals(gis.LineString({{2, 5}, {0, 0}}, 0), 10)
        ---
        - true
        ...

.. function:: ST.Equals(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.equals`.
    SQL-MM 3: 5.1.24.


.. method:: Geometry.disjoint(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if the geometries do not share any space together
    :rtype: boolean

    Returns true if the Geometries do not "spatially intersect" - if they
    do not share any space together

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.3.

    .. code-block:: lua

        tarantool> gis.Point({0, 0}, 0):disjoint(gis.LineString({{2, 0}, {0, 2}}, 0))
        ---
        - true
        ...

        tarantool> gis.Point({0, 0}, 0):disjoint(gis.LineString({{0, 0}, {0, 2}}, 0))
        ---
        - false
        ...

.. function:: ST.Disjoint(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.disjoint`.
    SQL-MM 3: 5.1.26.


.. method:: Geometry.intersects(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if the geometries "spatially intersect in 2D" -
              (share any portion of space)
    :rtype: boolean

    Returns true if the Geometries "spatially intersect in 2D" -
    (share any portion of space). Overlaps, Touches, Within all imply spatial
    intersection. If any of the aforementioned returns true, then the
    geometries also spatially intersect. Disjoint implies false for spatial
    intersection.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.3.

    .. code-block:: lua


        tarantool> gis.Point({0, 0}, 0):intersects(gis.LineString({{2, 0}, {0, 2}}, 0))
        ---
        - false
        ...

        tarantool> gis.Point({0, 0}, 0):intersects(gis.LineString({{0, 0}, {0, 2}}, 0))
        ---
        - true
        ...

.. function:: ST.Intersects(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.intersects`.
    SQL-MM 3: 5.1.27.


.. method:: Geometry.touches(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if the geometries have at least one point in common, but
              their interiors do not intersect.
    :rtype: boolean

    Returns true if the only points in common between g1 and g2 lie in the
    union of the boundaries of g1 and g2. This relation applies to all
    Area/Area, Line/Line, Line/Area, Point/Area and Point/Line pairs of
    relationships, but not to the Point/Point pair.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.3.

    .. code-block:: lua

        tarantool> gis.LineString({{0, 0}, {1, 1}, {0, 2}}, 0):touches(gis.Point({1,1}, 0))
        ---
        - false
        ...

        tarantool> gis.LineString({{0, 0}, {1, 1}, {0, 2}}, 0):touches(gis.Point({0,2}, 0))
        ---
        - true
        ...

.. function:: ST.Touches(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.touches`.
    SQL-MM 3: 5.1.28.


.. method:: Geometry.crosses(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if the supplied geometries have some, but not all,
              interior points in common.
    :rtype: boolean

    Returns true if intersection of geometries "spatially cross", that is,
    the geometries have some, but not all interior points in common.
    The intersection of the interiors of the geometries must not be the empty
    set and must have a dimensionality less than the maximum dimension of
    the two input geometries. Additionally, the intersection of the two
    geometries must not equal either of the source geometries. Otherwise, it
    returns false.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.3.

    .. code-block:: lua

        tarantool> gis.LineString({{0, 0}, {2, 2}}, 0):crosses(gis.LineString({{0, 2}, {2, 0}}, 0))
        ---
        - true
        ...

        tarantool> gis.LineString({{0, 0}, {2, 2}}, 0):crosses(gis.LineString({{0, 2}, {0, 8}}, 0))
        ---
        - false
        ...

.. function:: ST.Crosses(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.crosses`.
    SQL-MM 3: 5.1.29.


.. method:: Geometry.within(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if the geometry g1 is completely inside geometry g2
    :rtype: boolean

    Returns true if geometry g1 is completely inside geometry g2. For this
    unction to make sense, the source geometries must both be of the same
    coordinate projection, having the same SRID. It is a given that if
    `g1:within(g2) is true and `g2:within(g1)` is true, then the two
    geometries are considered spatially equal.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.3.

    .. code-block:: lua


        tarantool> gis.Point({1, 1}, 0):within(gis.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0))
        ---
        - true
        ...

        tarantool> gis.Point({0, 0}, 0):within(gis.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0))
        ---
        - false
        ...

.. function:: ST.Within(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.within`.
    SQL-MM 3: 5.1.30.


.. method:: Geometry.contains(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if and only if no points of g2 lie in the exterior of g1,
              and at least one point of the interior of g2 lies in the interior
              of g1.
    :rtype: boolean

    Geometry g1 contains Geometry g2 if and only if no points of g2 lie in the
    exterior of g1, and at least one point of the interior of g2 lies in the
    interior of g1.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.3.

    .. code-block:: lua


        tarantool> gis.LineString({{0, 0}, {2, 2}}, 0):contains(gis.Point({1, 1}, 0))
        ---
        - true
        ...

        tarantool> gis.LineString({{0, 0}, {2, 2}}, 0):contains(gis.Point({1, 5}, 0))
        ---
        - false
        ...

.. function:: ST.Contains(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.contains`.
    SQL-MM 3: 5.1.31.


.. method:: Geometry.overlaps(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if the Geometries share space, are of the same dimension,
              but are not completely contained by each other.
    :rtype: boolean

    Returns true if the Geometries "spatially overlap". By that we mean they
    intersect, but one does not completely contain another.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.3.

    .. code-block:: lua


        tarantool> gis.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0):overlaps(gis.Polygon({{{1, 1}, {1, 3}, {3, 3}, {3, 1}, {1, 1}}}, 0))
        ---
        - true
        ...

        tarantool> gis.Polygon({{{0, 0}, {0, 2}, {2, 2}, {2, 0}, {0, 0}}}, 0):overlaps(gis.Polygon({{{2, 2}, {2, 3}, {3, 3}, {3, 2}, {2, 2}}}, 0))
        ---
        - false
        ...

.. function:: ST.Overlaps(g1, g2)

    This function is a SQL/MM-compatible alias for :func:`Geometry.overlaps`.
    SQL-MM 3: 5.1.32.


.. method:: Geometry.covers(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if no point in Geometry g2 is outside Geometry g1
    :rtype: boolean

    Returns true if no point in Geometry g2 is outside Geometry g1.

    .. code-block:: lua


        tarantool> gis.Polygon({{{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}}}, 0):covers(gis.Polygon({{{0, 0}, {0, 3}, {3, 3}, {3, 0}, {0, 0}}}, 0))
        ---
        - true
        ...

        tarantool> gis.Polygon({{{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}}}, 0):covers(gis.Polygon({{{0, 0}, {0, 3}, {3, 3}, {5, 0}, {0, 0}}}, 0))
        ---
        - false
        ...

.. function:: ST.Covers(g1, g2)

    This function is an alias for :func:`Geometry.covers`.


.. method:: Geometry.coveredby(g2)

    :param g2: geometry
    :type  g2: geometry
    :returns: true if no point in Geometry g1 is outside Geometry g2
    :rtype: boolean

    Returns true if no point in Geometry g1 is outside Geometry g2.

    .. code-block:: lua


        tarantool> gis.Polygon({{{0, 0}, {0, 3}, {3, 3}, {3, 0}, {0, 0}}}, 0):coveredby(gis.Polygon({{{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}}}, 0))
        ---
        - true
        ...

        tarantool> gis.Polygon({{{0, 0}, {0, 3}, {3, 3}, {5, 0}, {0, 0}}}, 0):coveredby(gis.Polygon({{{0, 0}, {0, 4}, {4, 4}, {4, 0}, {0, 0}}}, 0))
        ---
        - false
        ...

.. function:: ST.CoveredBy(g1, g2)

    This function is an alias for :func:`Geometry.coveredby`.
