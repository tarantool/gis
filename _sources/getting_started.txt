Getting Started
===============

Please jump to `Using the Software`_ section if you are familiar with
Tarantool.

Prerequisites
`````````````

This software is a `module`_ for `Tarantool Database`_.
Tarantool 1.6.8 or newer is recommended. 

**Tarantool/GIS** depends on the following third-party libraries:

- `GEOS`_ (>= 3.4.0) - Geometry Engine - Open Source.
- `proj4`_ (>= 4.8) - cartographic projection software.

.. _module: http://rocks.tarantool.org/
.. _Tarantool Database: http://tarantool.org/
.. _GEOS: https://trac.osgeo.org/geos/
.. _proj4: https://github.com/OSGeo/proj.4

Installing GEOS and PROJ.4
``````````````````````````

Use the following command on Debian-based distros:

.. code-block:: bash

    sudo apt-get instal libgeos-dev libproj-dev # Debian/Ubuntu

Use the following command on RPM-based distros:

.. code-block:: bash

    sudo yum install geos-devel proj-devel # Fedora/RHEL/CentOS

Installing Tarantool and Tarantool/GIS
``````````````````````````````````````
Please install Tarantool using packages for your distribution
from http://tarantool.org/.

**Tarantool/GIS** also can be installed from the same repositories using
``tarantool-gis`` name.

.. code-block:: bash

    sudo apt-get install tarantool-gis # Debian/Ubuntu

.. code-block:: bash

    sudo yum install tarantool-gis # Fedora/RHEL/CentOS

Using the Software
``````````````````

Ensure that freshly installed Tarantool works:

.. code-block:: bash

    $ tarantool
    tarantool: version 1.6.8-701-g599ddf2
    type 'help' for interactive help
    tarantool> box.cfg({ logger = 'tarantool.log' })
    [CUT]
    tarantool> gis = require('gis')
    ---
    ...
    tarantool> gis.install()
    ---
    ...

:func:`gis.install()` function will create `spatial_ref_sys` and other system
tables in Tarantool.

Now you can use **Tarantool/GIS**:

.. code-block:: bash

    tarantool> point = gis.Point({37.17284, 55.74495}, 4326)
    tarantool> point
    ---
    - POINT (37.17284 55.74495) # WKT (for humans)
    ...

    tarantool> point:hex()
    ---
    - 010100000067B8019F1F964240DE9387855ADF4B40 # WKB HEX (for PostGIS users)
    ...

    tarantool> point:table()
    ---
    - [37.17284, 55.74495] # Lua Tables
    - 4326
    ...

    tarantool> box.space.spatial_ref_sys:get(4326)[4]
    ---
    - GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]]
    ...

Further Actions
```````````````

- Read :doc:`accessors` and :doc:`relationships` sections.
- Use :ref:`genindex` to find functions by its names.
- Checkout **examples** from
  `tests/ <https://github.com/tarantool/gis/tree/master/tests>`_ directory
- "Star" us the on `GitHub`_ and share for friends on `Facebook`_

.. _GitHub: http://github.com/tarantool/gis
.. _Facebook: https://www.facebook.com/sharer/sharer.php?u=http%3A//github.com/tarantool/gis
