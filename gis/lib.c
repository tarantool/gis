/*
 * Tarantool/GIS - a full-featured geospatial extension for Tarantool
 * (c) 2016 Roman Tsisyk <roman@tsisyk.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * The full text of the GNU Lesser General Public License version 2.1
 * can be found under the `COPYING.LGPL-2.1` file of this distribution.
 */

#include "lib.h"

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <geos_c.h>
#include <proj_api.h>
#include <tarantool/module.h>

#define LIBGEOS_VERSION(major, minor) (GEOS_VERSION_MAJOR > (major) || \
	(GEOS_VERSION_MAJOR == (major) && GEOS_VERSION_MINOR >= (minor)))

/*
 * Workarounds for iditioc GEOSMessageHandler API
 */

static char last_error[1024];

extern const char *
libgeos_last_error(void)
{
	return last_error;
}

#if LIBGEOS_VERSION(3, 5)
static void
libgeos_notice_handler(const char *message, void *userdata)
{
	(void) userdata;
	say_warn("GIS: %s", message);
}

static void
libgeos_error_handler(const char *message, void *userdata)
{
	(void) userdata;
	snprintf(last_error, sizeof(last_error), "%s", message);
}

extern GEOSContextHandle_t
libgeos_init_r()
{
	GEOSContextHandle_t handle = GEOS_init_r();
	GEOSContext_setNoticeMessageHandler_r(handle, libgeos_notice_handler,
					      NULL);
	GEOSContext_setErrorMessageHandler_r(handle, libgeos_error_handler,
					     NULL);
	return handle;
}

extern void
libgeos_finish_r(GEOSContextHandle_t handle)
{
	GEOS_finish_r(handle);
}

#else /* GEOS_VERSION < 3.5.0 */

static void
libgeos_set_error(const char *fmt, va_list ap)
{
	vsnprintf(last_error, sizeof(last_error), fmt, ap);
}

static void
libgeos_error_handler(const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
	libgeos_set_error(fmt, ap);
	va_end(ap);
}

static void
libgeos_notice_handler(const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
	libgeos_set_error(fmt, ap);
	va_end(ap);
	say_warn("GIS: %s", last_error);
}

extern GEOSContextHandle_t
libgeos_init_r()
{
	return initGEOS_r(libgeos_notice_handler, libgeos_error_handler);
}

extern void
libgeos_finish_r(GEOSContextHandle_t handle)
{
	finishGEOS_r(handle);
}
#endif

extern const char *
libproj_version(void)
{
	/* A workaround for very "smart" linker */
	return pj_get_release();
}
