/* Generated file by tools/headerversions, do not edit! */
/* GMP version: 6.1.2 */
/* SQLITE3 version: 3024000 */
/* ZLIB version: 1.2.11 */
#include <ccan/err/err.h>
#include <gmp.h>
#include <sqlite3.h>
#include <zlib.h>

static inline void check_linked_library_versions(void)
{
	char compiled_gmp_version[100];
	if (SQLITE_VERSION_NUMBER != sqlite3_libversion_number())
		errx(1, "SQLITE version mismatch: compiled %u, now %u",
		     SQLITE_VERSION_NUMBER, sqlite3_libversion_number());
	/* zlib documents that first char alters ABI. Kudos! */
	if (zlibVersion()[0] != ZLIB_VERSION[0])
		errx(1, "zlib version mismatch: compiled %s, now %s",
		     ZLIB_VERSION, zlibVersion());
	/* GMP doesn't say anything, and we have to assemble our own string. */
	snprintf(compiled_gmp_version,  sizeof(compiled_gmp_version),
		 "%u.%u.%u",
		 __GNU_MP_VERSION,
		 __GNU_MP_VERSION_MINOR,
		 __GNU_MP_VERSION_PATCHLEVEL);
	if (strcmp(compiled_gmp_version, gmp_version) != 0)
		errx(1, "gmp version mismatch: compiled %s, now %s",
		     compiled_gmp_version, gmp_version);
}
