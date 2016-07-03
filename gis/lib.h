typedef struct GEOSContextHandle_HS *GEOSContextHandle_t;
extern GEOSContextHandle_t
libgeos_init_r();
extern void
libgeos_finish_r(GEOSContextHandle_t handle);
extern const char *
libgeos_last_error(void);
extern const char *
libproj_version(void);
