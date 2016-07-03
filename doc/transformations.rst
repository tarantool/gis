Transformations
---------------

.. module:: gis

======================================== ========================================
SQL/MM                                   Lua
======================================== ========================================
:func:`ST.Transform`                     :func:`Geometry.transform`
======================================== ========================================

.. method:: Geometry.transform(tosrid)

    :param tosrid: Spatial Reference System Identifier
    :type  tosrid: uint32
    :returns: a new geometry
    :rtype: Geometry

    Returns a new geometry with its coordinates transformed to the SRID.

    SRID must be defined in `box.space.spatial_ref_sys`.
    :func:`Geometry.transform` uses `PROJ.4`_ library for conversion.

    .. _PROJ.4: https://github.com/OSGeo/proj.4

    .. code-block:: lua

        tarantool> point = gis.Point({37.17284, 55.74495}, 4326)
        ---
        ...

        tarantool> point:transform(4328) -- GeoCentered
        ---
        - POINT Z (2867223.87796052 2174199.925113969 5248510.410253408)
        ...

        tarantool> point:transform(32644) -- UTM
        ---
        - POINT (-2129579.994461996 7080150.495815906)
        ...

        tarantool> gis.LineString({{37.279357, 55.849493}, {37.275152, 55.865005}}, 4326):transform(4328)
        ---
        - LINESTRING Z (2855517.134262041 2173695.700583999 5255053.314718033, 2854539.218976094
          2172620.409320028 5256022.657867197)
        ...

        tarantool> box.space.spatial_ref_sys:get(4326)[5]
        ---
        - '+proj=longlat +datum=WGS84 +no_defs '
        ...


.. function:: ST.Transform(geometry, tosrid)

    This function is a SQL/MM-compatible alias for
    :func:`Geometry.transform`. SQL-MM 3: 5.1.6.


