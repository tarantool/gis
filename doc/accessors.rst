Accessors
---------

.. module:: gis

======================================== ========================================
SQL/MM                                   Lua
======================================== ========================================
:func:`ST.GeometryType`                  :func:`Geometry.type`
:func:`ST.GeometryTypeId`                :func:`Geometry.typeid`
:func:`ST.SRID`                          :func:`Geometry.srid`
:func:`ST.Boundary`                      :func:`Geometry.boundary`
:func:`ST.Envelope`                      :func:`Geometry.envelope`
:func:`ST.IsCollection`                  :func:`Geometry.iscollection`
:func:`ST.NumGeometries`                 :func:`GeometryCollection.numgeometries`
:func:`ST.GeometryN`                     :func:`GeometryCollection.geometryn`
                                         :func:`GeometryCollection.geometry`
                                         :func:`GeometryCollection.geometries`
                                         :func:`GeometryCollection.itergeometries`
:func:`ST.NumPoints`                     :func:`Curve.numpoints`
:func:`ST.PointN`                        :func:`Curve.pointn`
                                         :func:`Curve.point`
                                         :func:`Curve.points`
                                         :func:`Curve.iterpoints`
:func:`ST.ExteriorRing`                  :func:`Polygon.exteriorring`
                                         :func:`Polygon.shell`
:func:`ST.NumInteriorRings`              :func:`Polygon.numinteriorrings`
                                         :func:`Polygon.numholes`
:func:`ST.InteriorRingN`                 :func:`Polygon.interiorringn`
                                         :func:`Polygon.interiorring`
                                         :func:`Polygon.hole`
                                         :func:`Polygon.holes`
                                         :func:`Polygon.iterholes`
:func:`ST.X`                             :func:`Point.x`
:func:`ST.Y`                             :func:`Point.y`
:func:`ST.Y`                             :func:`Point.z`
======================================== ========================================

.. method:: Geometry.type()

    :returns: geometry type
    :rtype: string

    Returns geometry type name.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.2.

    .. code-block:: lua

        tarantool> gis.Point({37.17284, 55.74495}, 4326):type()
        ---
        - Point
        ...

.. function:: ST.GeometryType(geometry)

    This function is a SQL/MM-compatible alias for
    :func:`Geometry.type`. SQL-MM 3: 5.1.4.


.. method:: Geometry.typeid()

    :returns: geometry type id
    :rtype: integer

    Returns geometry type id.

    .. code-block:: lua

        tarantool> gis.LineString({{37.279357, 55.849493}, {37.275152, 55.865005}}, 4326):typeid()
        ---
        - 1
        ...

.. function:: ST.GeometryTypeId(geometry)

    This function is an alias for :func:`Geometry.typeid`.


.. method:: Geometry.srid()

    :returns:  Spatial Reference System Identifier
    :rtype: uint32

    Returns the spatial reference identifier.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.2.

    .. code-block:: lua

        tarantool> gis.Point({37.17284, 55.74495}, 4326):srid()
        ---
        - 4326
        ...

.. function:: ST.SRID(geometry)

    This function is a SQL/MM-compatible alias for
    :func:`Geometry.srid`. SQL-MM 3: 5.1.5.


.. method:: Geometry.boundary()

    :returns: closure
    :rtype: Geometry

    Returns the closure of the combinatorial boundary of this geometric object.
    Because the result of this function is a closure, and hence topologically
    closed, the resulting boundary can be represented using representational
    Geometry primitives.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.2.

    .. code-block:: lua

        tarantool> gis.Polygon({ {{10, 130}, {50, 190}, {110, 190}, {140, 150}, {150, 80}, {100, 10}, {20, 40}, {10, 130}},
                 > {{70, 40}, {100, 50}, {120, 80}, {80, 110}, {50, 90}, {70, 40}} }, 0):boundary()
        ---
        - MULTILINESTRING ((10 130, 50 190, 110 190, 140 150, 150 80, 100 10, 20 40, 10 130),
          (70 40, 100 50, 120 80, 80 110, 50 90, 70 40))
        ...

.. function:: ST.Boundary(geometry)

    This function is a SQL/MM-compatible alias for :func:`Geometry.boundary`.
    SQL-MM 3: 5.1.14.


.. method:: Geometry.envelope()

    :returns: minimum bounding box
    :rtype: Polygon

    Returns the minimum bounding box for this Geometry.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.2.2.

    .. code-block:: lua

        tarantool> gis.Polygon({{{10, 130}, {50, 190}, {110, 190}, {140, 150}, {150, 80}, {100, 10}, {20, 40}, {10, 130}}}, 0):envelope()
        ---
        - POLYGON ((10 10, 150 10, 150 190, 10 190, 10 10))
        ...

.. function:: ST.Envelope(geometry)

    This function is a SQL/MM-compatible alias for :func:`Geometry.boundary`.
    SQL-MM 3: 5.1.15.



.. method:: Geometry.iscollection()

    :returns: true if geometry is collection
    :rtype: boolean

    Returns true if geometry is a collection. See :doc:`types` for
    details.

    .. code-block:: lua

        tarantool> gis.Point({37.17284, 55.74495}, 4326):iscollection()
        ---
        - false
        ...

        tarantool> gis.MultiPoint({{37.279357, 55.849493}, {37.275152, 55.865005}}, 4326):iscollection()
        ---
        - true
        ...

.. function:: ST.IsCollection(geometry)

    This function is a PostGIS-compatible alias for
    :func:`Geometry.iscollection`.


.. method:: Point.x()

    :returns: x-coordinate
    :rtype: double

    Returns the x-coordinate value for this point.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.4.2.

    .. code-block:: lua

        tarantool> gis.Point({37.17284, 55.74495}, 4326):x()
        ---
        - 37.17284
        ...

.. function:: ST.X(point)

    This function is a SQL/MM-compatible alias for :func:`Point.x`.
    SQL-MM 3: 6.1.3.


.. method:: Point.y()

    :returns: y-coordinate
    :rtype: double

    Returns the y-coordinate value for this point.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.4.2.

    .. code-block:: lua

        tarantool> gis.Point({37.17284, 55.74495}, 4326):y()
        ---
        - 55.74495
        ...

.. function:: ST.Y(point)

    This function is a SQL/MM-compatible alias for :func:`Point.y`.
    SQL-MM 3: 6.1.4.


.. method:: Point.z()

    :returns: z-coordinate
    :rtype: double or nil
    :raises: on error

    Returns the z-coordinate value for this point if it has one. Returns
    ``nil`` otherwise.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.4.2.

    .. code-block:: lua

        tarantool> gis.Point({37.17284, 55.74495}, 4326):z()
        ---
        - null
        ...

        tarantool> gis.Point({2867223.8779605, 2174199.925114, 5248510.4102534}, 4328):z()
        ---
        - 5248510.4102534
        ...

.. function:: ST.Z(point)

    This function is a SQL/MM-compatible alias for :func:`Point.z`.
    SQL-MM 3: 6.1.5.


.. method:: Curve.numpoints()

    :returns: the number of points in a curve
    :rtype: integer
    :raises: on error

    Returns the number of points in a :class:`Curve`.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.7.2.

    See :func:`Curve.point` for examples.

.. function:: ST.NumPoints(curve)

    This function is a SQL/MM-compatible alias for :func:`Curve.numpoints`.
    SQL-MM 3: 7.2.4.


.. method:: Curve.point(n)
            Curve.pointn(n)

    :param n: one-based index
    :type  n: integer
    :returns: Nth point of a curve
    :rtype: Point

    Returns Nth point of a curve. Returns nil if n is out of
    bounds.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.7.2.

    .. code-block:: lua

        tarantool> linestring = gis.LineString({{37.279357, 55.849493}, {37.275152, 55.865005}}, 4326)
        ---
        ...

        tarantool> linestring:numpoints()
        ---
        - 2
        ...

        tarantool> linestring:pointn(1)
        ---
        - POINT (37.279357 55.849493)
        ...

        tarantool> linestring:pointn(3)
        ---
        - null
        ...

        tarantool> linestring:points()
        ---
        - - POINT (37.279357 55.849493)
          - POINT (37.275152 55.865005)
        ...
        tarantool> for i, point in linestring:iterpoints() do print(i, point) end
        1       POINT (37.279357 55.849493)
        2       POINT (37.275152 55.865005)
        ---
        ...

.. function:: ST.PointN(curve)

    This function is a SQL/MM-compatible alias for :func:`Curve.pointn`.
    SQL-MM 3: 7.2.5.


.. method:: Curve.points()

    :returns: array of points of a curve
    :rtype: [Point]
    :raises: on error

    Returns a Lua table with points of this collection. This method
    also supports non-collections geometric types.

    See :func:`Curve.pointn` for examples.


.. method:: Curve.iterpoints()

    :returns: iterator over points of this curve
    :rtype: Lua iterator (gen, param, state)
    :raises: on error

    Returns a Lua iterator (gen, param, state) over points of this curve.

    See :func:`Curve.pointn` for examples.


.. method:: Polygon.shell()
            Polygon.exteriorring()

    :returns: a linear ring representing the exterior ring of a polygon
    :rtype: LinearRing

    Returns a linear ring representing the exterior ring of a polygon.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.11.2.

    .. code-block:: lua

        tarantool> shell = {
                 >     {37.279357, 55.849493};
                 >     {37.275152, 55.865005};
                 >     {37.261676, 55.864041};
                 >     {37.279357, 55.849493};
                 > }
        ---
        ...

        tarantool> gis.Polygon({shell}, 4326)
        ---
        - POLYGON ((37.279357 55.849493, 37.275152 55.865005, 37.261676 55.864041, 37.279357
          55.849493))
        ...

        tarantool> polygon:exteriorring()
        ---
        - LINEARRING (37.279357 55.849493, 37.275152 55.865005, 37.261676 55.864041, 37.279357
          55.849493)
        ...

.. function:: ST.ExteriorRing(polygon)

    This function is a SQL/MM-compatible alias for :func:`Polygon.exteriorring`.
    SQL-MM 3: 8.2.3.


.. method:: Polygon.numholes()
            Polygon.numinteriorrings()

    :returns: return the number of interior rings of a polygon
    :rtype: integer

    Returns the number of interior rings of a polygon.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.11.2.

    See :func:`Polygon.hole` for examples.

.. function:: ST.NumInteriorRings(polygon)

    This function is a SQL/MM-compatible alias for
    :func:`Polygon.numinteriorrings`. SQL-MM 3: 8.2.5.


.. method:: Polygon.hole(n)
            Polygon.interiorring(n)
            Polygon.interiorringn(n)


    :param n: one-based index
    :type  n: integer
    :returns: Nth interior ring of a polygon
    :rtype: LinearRing

    Returns Nth interior ring of a polygon. Returns nil if n is out of
    bounds.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.11.2.

    .. code-block:: lua

        tarantool> shell = {
                 >     {37.279357, 55.849493};
                 >     {37.275152, 55.865005};
                 >     {37.261676, 55.864041};
                 >     {37.279357, 55.849493};
                 > }
        ---
        ...

        tarantool> hole = {
                 >     {37.267856, 55.853781};
                 >     {37.269401, 55.858502};
                 >     {37.273864, 55.854937};
                 >     {37.267856, 55.853781};
                 > }
        ---
        ...

        tarantool> gis.Polygon({shell, hole}, 4326)
        ---
        - POLYGON ((37.279357 55.849493, 37.275152 55.865005, 37.261676 55.864041, 37.279357
          55.849493), (37.267856 55.853781, 37.269401 55.858502, 37.273864 55.854937, 37.267856
          55.853781))
        ...

        tarantool> polygon:numholes()
        ---
        - 1
        ...

        tarantool> polygon:hole(1)
        ---
        - LINEARRING (37.267856 55.853781, 37.269401 55.858502, 37.273864 55.854937, 37.267856
          55.853781)
        ...

        tarantool> polygon:hole(2)
        ---
        - null
        ...


.. function:: ST.InteriorRingN(polygon)

    This function is a SQL/MM-compatible alias for
    :func:`Polygon.interiorringn`. SQL-MM 3: 8.2.6.



.. method:: Polygon.holes()
            Polygon.interiorrings()

    :returns: array of interior rings of a polygon
    :rtype: [LinearRing]
    :raises: on error

    Returns a Lua table with interior rings of this polygon.

    See also :func:`Polygon.iterholes` and :func:`Polygon.hole`.

    .. code-block:: lua

        tarantool> polygon:holes()
        ---
        - - LINEARRING (37.267856 55.853781, 37.269401 55.858502, 37.273864 55.854937, 37.267856
            55.853781)
        ...


.. method:: Polygon.iterholes()
            Polygon.iterinteriorrings()

    :returns: iterator over interior rings of this polygon
    :rtype: Lua iterator (gen, param, state)

    Returns a Lua iterator (gen, param, state) over interior rings of this
    polygon.

    See also :func:`Polygon.holes` and :func:`Polygon.hole`.

    .. code-block:: lua

        tarantool> for i, hole in polygon:iterholes() do print(i, hole) end
        1       LINEARRING (37.267856 55.853781, 37.269401 55.858502, 37.273864 55.854937, 37.267856 55.853781)
        ---
        ...


.. method:: GeometryCollection.numgeometries()

    :returns: the number of geometries in the collection
    :rtype: integer
    :raises: on error

    Returns the number of geometries in this GeometryCollection.
    This method also supports non-collections geometric types.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.3.2.

    See :meth:`GeometryCollection.geometryn` for examples.

.. function:: ST.NumGeometries(collection)

    This function is a SQL/MM-compatible alias for
    :func:`GeometryCollection.NumGeometries`. SQL-MM 3: 9.1.4.


.. method:: GeometryCollection.geometry(n)
            GeometryCollection.geometryn(n)

    :param n: one-based index
    :type  n: integer
    :returns: idx-geometry of a collection
    :rtype: Geometry
    :raises: on error

    Returns Nth-geometry of this collection. Returns nil if n is out of
    bounds. This method also supports non-collections geometric types.

    This method implements OpenGIS® Simple Feature Access specification.
    OGC 06-103r4 6.1.3.2.

    .. code-block:: lua

        tarantool> collection = gis.MultiPoint({{37.279357, 55.849493}, {37.275152, 55.865005}}, 4326)
        ---
        ...

        tarantool> collection:numgeometries()
        ---
        - 2
        ...

        tarantool> collection:geometryn(1)
        ---
        - POINT (37.279357 55.849493)
        ...

        tarantool> collection:geometryn(3)
        ---
        - null
        ...

        tarantool> collection:geometries()
        ---
        - - POINT (37.279357 55.849493)
          - POINT (37.275152 55.865005)
        ...
        tarantool> for i, geom in collection:itergeometries() do print(i, geom) end
        1       POINT (37.279357 55.849493)
        2       POINT (37.275152 55.865005)
        ---
        ...

.. function:: ST.GeometryN(collection)

    This function is a SQL/MM-compatible alias for
    :func:`GeometryCollection.geometryn`. SQL-MM 3: 9.1.5.


.. method:: GeometryCollection.geometries()

    :returns: array of geometries of this collection
    :rtype: [Geometry]

    Returns a Lua table with geometries of this collection. This method
    also supports non-collections geometric types.

    See also :func:`GeometryCollection.geometry` for examples.

.. function:: ST.Dump(collection)

    This function is a PostGIS-compatible alias for
    :func:`GeometryCollection.geometries`.


.. method:: GeometryCollection.itergeometries()

    :returns: iterator over geometries in this collection
    :rtype: Lua iterator (gen, param, state)

    Returns a Lua iterator (gen, param, state) over geometries of this
    collection.

    See also :func:`GeometryCollection.geometry` for examples.
