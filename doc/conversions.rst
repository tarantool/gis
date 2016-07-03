Conversions
-----------

.. module:: gis

======================================== ========================================
SQL/MM                                   Lua
======================================== ========================================
:func:`ST.GeomFromWKT`                   :func:`wkt.decode`
:func:`ST.AsWKT`                         :func:`wkt.encode`
                                         :func:`Geometry.wkt`
:func:`ST.GeomFromWKB`                   :func:`wkb.decode`
:func:`ST.AsWKB`                         :func:`wkb.encode`
                                         :func:`Geometry.wkb`
:func:`ST.GeomFromHEXWKB`                :func:`wkb.decode_hex`
:func:`ST.AsHEXWKB`                      :func:`wkb.encode_hex`
                                         :func:`Geometry.hexwkb`
                                         :func:`Geometry.hex`
:func:`ST.AsTable`                       :func:`Geometry.table`
======================================== ========================================

.. function:: wkt.decode(wkt, srid)

    :param wkt: Well-Known Text
    :type  wkt: string
    :param srid: Spatial Reference System Identifier
    :type  srid: uint
    :returns: a new geometry
    :rtype: Geometry

    Constructs Geometry from Well-Known Text (WKT).

    .. code-block:: lua

        tarantool> gis.wkt.decode('POINT (37.17284 55.74495)', 4326)
        ---
        - POINT (37.17284 55.74495)
        ...

.. function:: ST.GeomFromWKT(wkt, srid)
              ST.GeomFromText(wkt, srid)

    These function are PostGIS-compatible aliases for :func:`wkt.decode`.


.. function:: wkt.encode(geometry)

    :param geometry: geometry
    :type  geometry: Geometry
    :returns: Well-Known Text
    :rtype: string

    Return the Well-Known Text (WKT) representation of the geometry.
    These function lose SRID information.

    WKT format does not maintain precision so please use WKB to prevent
    floating truncation.

    .. code-block:: lua

        tarantool> point = gis.Point({37.17284, 55.74495}, 4326)
        ---
        ...

        tarantool> point:wkt()
        ---
        - POINT (37.17284 55.74495)
        ...

        tarantool> tostring(point)
        ---
        - POINT (37.17284 55.74495)
        ...

.. method:: Geometry.wkt()

    An alias for :func:`wkt.encode`.

.. function:: ST.AsWKT(geometry)
              ST.AsText(geometry)

    These function are PostGIS-compatible aliases for :func:`wkt.encode`.

.. function:: wkb.decode(wkb, srid)

    :param wkt: Well-Known Binary
    :type  wkt: string
    :param srid: Spatial Reference System Identifier
    :type  srid: uint
    :returns: a new geometry
    :rtype: Geometry

    Constructs Geometry from Well-Known Binary (WKB).

    .. code-block:: lua

        tarantool> wkb = "\x01\x01\x00\x00\x00\x67\xB8\x01\x9F\x1F\x96\x42\x40\xDE\x93\x87\x85\x5A\xDF\x4B\x40"
        ---
        ...

        tarantool> gis.wkb.decode(wkb, 4326)
        ---
        - POINT (37.17284 55.74495)
        ...

.. function:: ST.GeomFromWKB(wkb, srid)
              ST.GeomFromText(wkb, srid)

    These function are PostGIS-compatible aliases for :func:`wkb.decode`.

.. function:: wkb.decode_hex(hexwkb, srid)

    :param hexwkb: Well-Known Binary as HEX
    :type  hexwkb: string
    :param srid: Spatial Reference System Identifier
    :type  srid: uint
    :returns: a new geometry
    :rtype: Geometry

    Constructs Geometry from Well-Known Binary (WKB) encoded as HEX.

    .. code-block:: lua

        tarantool> hexwkb = "010100000067B8019F1F964240DE9387855ADF4B40"
        ---
        ...

        tarantool> gis.wkb.decode_hex(hexwkb, 4326)
        ---
        - POINT (37.17284 55.74495)
        ...

.. function:: ST.GeomFromHEXWKB(hexwkb, srid)

    This function is an alias for :func:`wkb.decode_hex`.

.. function:: wkb.encode(geometry)

    :param geometry: geometry
    :type  geometry: Geometry
    :returns: Well-Known Binary
    :rtype: string

    Return the Well-Known Binary (WKB) representation of the geometry.
    These function lose SRID information.

    .. code-block:: lua

        tarantool> point:wkb()
        ---
        - !!binary AQEAAABnuAGfH5ZCQN6Th4Va30tA
        ...

        tarantool> point:hexwkb()
        ---
        - 010100000067B8019F1F964240DE9387855ADF4B40
        ...

.. function:: wkb.encode_hex(geometry)

    :param geometry: geometry
    :type  geometry: Geometry
    :returns: Well-Known Binary (WKB) encoded as HEX
    :rtype: string

    Return the Well-Known Binary (WKB) representation of the geometry
    encoded as HEX string.

    These function lose SRID information.

    .. code-block:: lua

        tarantool> point:hexwkb()
        ---
        - 010100000067B8019F1F964240DE9387855ADF4B40
        ...

.. method:: Geometry.wkb()

    An alias for :func:`wkb.encode`.

.. method:: Geometry.hexwkb()
            Geometry.hex()

    Aliases for :func:`wkb.encode_hex`.

.. function:: ST.AsWKB(geometry)
              ST.AsBinary(geometry)

    These function are PostGIS-compatible aliases for :func:`wkb.encode`.

.. function:: ST.AsHEXWKB(geometry)

    This function is an alias for :func:`wkb.encode_hex`.


.. method:: Geometry.table()
            Geometry.totable()

    :returns: Lua Table suitable for constructor
    :rtype: table

    Returns ``table, srid`` suitable for a constructor of appropriate type.

    .. code-block:: lua

        tarantool> gis.Point({37.17284, 55.74495}, 4326):totable()
        ---
        - [37.17284, 55.74495]
        - 4326
        ...

        tarantool> gis.LineString({{37.279357, 55.849493}, {37.275152, 55.865005}}, 4326):totable()
        ---
        - [[37.279357, 55.849493], [37.275152, 55.865005]]
        - 4326
        ...

        tarantool> gis.Point(gis.Point({37.17284, 55.74495}, 4326):totable())
        ---
        - POINT (37.17284 55.74495)
        ...

.. function:: ST.AsTable(geometry)

    This function is an alias for :func:`Geometry.table`.
