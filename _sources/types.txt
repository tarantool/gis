Types
=====

.. module:: gis

This section describes the object model for simple feature geometry and
classs to create geometry features from Lua objects.

======================================== ========================================
SQL/MM                                   Lua
======================================== ========================================
:func:`ST.Point`                         :class:`gis.Point`
:func:`ST.LineString`                    :class:`gis.LineString`
:func:`ST.LinearRing`                    :class:`gis.LinearRing`
:func:`ST.Polygon`                       :class:`gis.Polygon`
:func:`ST.GeometryCollection`            :class:`gis.GeometryCollection`
:func:`ST.MultiPoint`                    :class:`gis.MultiPoint`
:func:`ST.MultiLineString`               :class:`gis.MultiLineString`
:func:`ST.MultiPolygon`                  :class:`gis.MultiPolygon`
======================================== ========================================

.. figure:: hierarchy.png
   :alt: Geometry class hierarchy


.. class:: Geometry

    Geometry is the root class of the hierarchy. Geometry is an abstract
    (non-instantiable) class.

.. class:: Point({lon, lat}, srid)
           Point({x, y}, srid)
           Point({x, y, z}, srid)

    :param x: x
    :type  x: number
    :param y: y
    :type  y: number
    :param z: z
    :type  z: number
    :param srid: Spatial Reference System Identifier
    :type  srid: uint
    :returns: point
    :rtype: Point
    :raises: on error

    A Point is a 0-dimensional :class:`geometric <Geometry>` object and
    represents a single location in coordinate space.

    .. code-block:: lua

        tarantool> gis.Point({37.17284, 55.74495}, 4326)
        ---
        - POINT (37.17284 55.74495)
        ...

        tarantool> gis.Point({2867223.8779605, 2174199.925114, 5248510.4102534}, 4328)
        ---
        - POINT Z (2867223.8779605 2174199.925114 5248510.4102534)
        ...

.. class:: Curve

    A Curve is a 1-dimensional :class:`geometric <Geometry>` object usually
    stored as a sequence of :class:`Points <Point>`, with the subtype of Curve
    specifying the form of the interpolation between Points. ISO 19123 standard
    defines only one subclass of Curve, :class:`LineString`, which uses linear
    interpolation between Points. Curve is an abstract (non-instantiable) class.

.. class:: LineString({{lon, lat}, point, {lon, lat}, ...}, srid)
           LineString({{x, y}, point, {x, y}, ...}, srid)
           LineString({{x, y, z}, point, {x, y}, ...}, srid)
           LineString(linestring, srid)
           LineString(linearring, srid)

   :param x: x
   :type  x: double
   :param y: y
   :type  y: double
   :param z: z
   :type  z: double
   :param point: point
   :type  point: Point
   :param linestring: linestring
   :type  linestring: LineString
   :param linearring: linearring
   :type  linearring: LinearRing
   :param srid: Spatial Reference System Identifier
   :type  srid: integer
   :returns: linestring
   :rtype: LineString

   A LineString is a :class:`Curve` with linear interpolation between
   :class:`Points <Point>`. Each consecutive pair of Points defines a
   :class:`Line` segment.

   .. code-block:: lua

    tarantool> gis.LineString({{37.279357, 55.849493}, {37.275152, 55.865005}, gis.Point({37.261676, 55.864041}, 4326)}, 4326)
    ---
    - LINESTRING (37.279357 55.849493, 37.275152 55.865005, 37.261676 55.864041)
    ...


   .. code-block:: lua

    tarantool> gis.LineString({{2855517, 2173695, 5255053}, {2854539, 2172620, 5256022}, {2855120, 2172002, 5255962}}, 4328)                          
    ---
    - LINESTRING Z (2855517 2173695 5255053, 2854539 2172620 5256022, 2855120 2172002
      5255962)
    ...


.. class:: LinearRing({{lon, lat}, point, {lon, lat}, ...}, srid)
           LinearRing({{x, y}, point, {x, y}, ...}, srid)
           LinearRing({{x, y, z}, point, {x, y}, ...}, srid)
           LinearRing(linestring, srid)
           LinearRing(linearring, srid)

   :param x: x
   :type  x: double
   :param y: y
   :type  y: double
   :param z: z
   :type  z: double
   :param point: point
   :type  point: Point
   :param linestring: linestring
   :type  linestring: LineString
   :param linearring: linearring
   :type  linearring: LinearRing
   :param srid: Spatial Reference System Identifier
   :type  srid: integer
   :returns: linearring
   :rtype: LinearRing

   A LinearRing is a :class:`LineString` that is both closed and simple.

   .. code-block:: lua

    tarantool> gis.LinearRing({{37.279357, 55.849493}, {37.275152, 55.865005}, {37.261676, 55.864041}, {37.279357, 55.849493}}, 4326)                  
    ---
    - LINEARRING (37.279357 55.849493, 37.275152 55.865005, 37.261676 55.864041, 37.279357
      55.849493)
    ...


.. class:: Line

   A Line is a :class:`LineString` with exactly 2 :class:`Points`.

   Tarantool/GIS doesn't provide this subclass, please use :class:`LineString`
   instead.


.. class:: Surface

   A Surface is a 2-dimensional :class:`geometric <Geometry>` object. A simple
   Surface may consists of a single “patch” that is associated with one
   "exterior boundary" and 0 or more "interior" boundaries.
   A single such Surface patch in 3-dimensional space is isometric to planar
   Surfaces, by a simple affine rotation matrix that rotates the patch onto
   the plane z = 0. If the patch is not vertical, the projection onto the same
   plane is an isomorphism, and can be represented as a linear transformation,
   i.e. an affine.


.. class:: Polygon({ {{x, y, z}, point, ...}, linearring, ...}, srid)

    :param x: x
    :type  x: double
    :param y: y
    :type  y: double
    :param z: z
    :type  z: double
    :param point: point
    :type  point: Point
    :param linearring: linearring
    :type  linearring: LinearRing
    :param srid: Spatial Reference System Identifier
    :type  srid: integer
    :returns: Polygon
    :rtype: Polygon

    A Polygon is a planar :class:`Surface` defined by 1 exterior boundary and
    0 or more interior boundaries. Each interior boundary defines a hole in the
    Polygon. The exterior boundary :class:`LinearRing` defines the "top" of the
    surface which is the side of the surface from which the exterior boundary
    appears to traverse the boundary in a counter clockwise direction. The
    interior :class:`LinearRings <LinearRing>` will have the opposite
    orientation, and appear as clockwise when viewed from the "top".

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

.. class:: Triangle

   A Triangle is a :class:`Polygon` with 3 distinct, non-collinear vertices
   and no interior boundaries. Tarantool/GIS doesn't provide this subclass,
   please use :class:`Polygon` instead.


.. class:: PolyhedralSurface

   A PolyhedralSurface is a contiguous collection of polygons, which share
   common boundary segments. For each pair of polygons that "touch",
   the common boundary shall be expressible as a finite collection of
   :class:`LineStrings <LineString>`. Each such :class`LineString` shall be
   part of the boundary of at most 2 Polygon patches.

   Tarantool/GIS currently doesn't implement this feature.


.. class:: TIN

   **Inherits** :class:`Surface`

   A TIN (triangulated irregular network) is a :class:`PolyhedralSurface`
   consisting only of Triangle patches.

   Tarantool/GIS currently doesn't implement this feature.


.. class:: GeometryCollection({geometry, geometry, ...}, srid)

   :param geometry: geometry
   :type  geometry: Geometry
   :param srid: Spatial Reference System Identifier
   :type  srid: integer
   :returns: collection
   :rtype: GeometryCollection

   A GeometryCollection is a geometric object that is a collection of some
   number of geometric objects. All the elements in a GeometryCollection
   shall be in the same Spatial Reference System. This is also the Spatial
   Reference System for the GeometryCollection. GeometryCollection places no
   other constraints on its elements. Subclasses of GeometryCollection may
   restrict membership based on dimension and may also place other constraints
   on the degree of spatial overlap between elements.

   .. code-block:: lua

        tarantool> point = gis.Point({37.17284, 55.74495}, 4326)
        ---
        ...

        tarantool> linestring = gis.LineString({{37.275152, 55.865005}, {37.261676, 55.864041}}, 4326)
        ---
        ...

        tarantool> gis.GeometryCollection({point, linestring}, 4326)
        ---
        - GEOMETRYCOLLECTION (POINT (37.17284 55.74495), LINESTRING (37.275152 55.865005,
          37.261676 55.864041))
        ...


.. class:: MultiPoint({{lon, lat}, point, {lon, lat}, ...}, srid)
           MultiPoint({{x, y}, point, {x, y}, ...}, srid)
           MultiPoint({{x, y, z}, point, {x, y}, ...}, srid)
           MultiPoint(linestring, srid)
           MultiPoint(linearring, srid)

   :param x: x
   :type  x: double
   :param y: y
   :type  y: double
   :param z: z
   :type  z: double
   :param point: point
   :type  point: Point
   :param linestring: linestring
   :type  linestring: LineString
   :param linearring: linearring
   :type  linearring: LinearRing
   :param srid: Spatial Reference System Identifier
   :type  srid: integer
   :returns: multipoint
   :rtype: MultiPoint

   A MultiPoint is a 0-dimensional :class:`GeometryCollection`. The elements
   of a MultiPoint are restricted to :class:`Points <Point>`. The Points are
   not connected or ordered in any semantically important way. A MultiPoint is
   simple if no two Points in the MultiPoint are equal (have identical
   coordinate values in X and Y).The boundary of a MultiPoint is the empty set.

   .. code-block:: lua

    tarantool> gis.MultiPoint({{37.279357, 55.849493}, {37.275152, 55.865005}}, 4326)
    ---
    - MULTIPOINT (37.279357 55.849493, 37.275152 55.865005)
    ...


.. class:: MultiCurve

   A MultiCurve is a 1-dimensional :class:`GeometryCollection` whose elements
   are :class:`Curves <Curve>`. This class is an abstract.


.. class:: MultiLineString({ {{x, y, z}, point, ...}, linestring, linearring, ...}, srid)

   :param x: x
   :type  x: double
   :param y: y
   :type  y: double
   :param z: z
   :type  z: double
   :param point: point
   :type  point: Point
   :param linestring: linestring
   :type  linestring: LineString
   :param linearring: linearring
   :type  linearring: LinearRing
   :param srid: Spatial Reference System Identifier
   :type  srid: integer
   :returns: MultiLineString
   :rtype: MultiLineString

   A MultiLineString is a :class:`MultiCurve` whose elements are LineStrings.

   .. code-block:: lua

    tarantool> linestrings = {
             >     {
             >         {37.279357, 55.849493};
             >         {37.275152, 55.865005};
             >         {37.261676, 55.864041};
             >     };
             >     gis.LineString({
             >         {37.267856, 55.853781};
             >         {37.269401, 55.858502};
             >         {37.273864, 55.854937};
             >     }, 4326);
             > }
    ---
    ...

    tarantool> gis.MultiLineString(linestrings, 4326)
    ---
    - MULTILINESTRING ((37.279357 55.849493, 37.275152 55.865005, 37.261676 55.864041),
      (37.267856 55.853781, 37.269401 55.858502, 37.273864 55.854937))
    ...


.. class:: MultiSurface

   A MultiSurface is a 2-dimensional :class:`GeometryCollection` whose
   elements are :class:`Surfaces <Surface>`, all using coordinates from the
   same coordinate reference system. The geometric interiors of any two
   Surfaces in a MultiSurface may not intersect in the full coordinate system.
   The boundaries of any two coplanar elements in a MultiSurface may intersect,
   at most, at a finite number of Points. If they were to meet along a curve,
   they could be merged into a single surface.

   This class is an abstract in Tarantool/GIS.


.. class:: MultiPolygon({polygon, {{{x, y, z}, point, ...}, linearring, ...}, ... }, srid)

   :param x: x
   :type  x: double
   :param y: y
   :type  y: double
   :param z: z
   :type  z: double
   :param point: point
   :type  point: Point
   :param linearring: linearring
   :type  linearring: LinearRing
   :param polygon: polygon
   :type  polygon: Polygon
   :param srid: Spatial Reference System Identifier
   :type  srid: integer
   :returns: multipolygon
   :rtype: MultiPolygon

   A MultiPolygon is a :class:`MultiSurface` whose elements are
   :class:`Polygons <Polygon>`.

   .. code-block:: lua

    tarantool> polygons = {
             >     {{
             >         {37.279357, 55.849493};
             >         {37.275152, 55.865005};
             >         {37.261676, 55.864041};
             >         {37.279357, 55.849493};
             >     }};
             >     {{
             >         {37.267856, 55.853781};
             >         {37.269401, 55.858502};
             >         {37.273864, 55.854937};
             >         {37.267856, 55.853781};
             >     }};
             > }
    ---
    ...

    tarantool> gis.MultiPolygon(polygons, 4326)
    ---
    - MULTIPOLYGON (((37.279357 55.849493, 37.275152 55.865005, 37.261676 55.864041, 37.279357
      55.849493)), ((37.267856 55.853781, 37.269401 55.858502, 37.273864 55.854937, 37.267856
      55.853781)))
    ...
