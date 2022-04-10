#include <glib.h>
#include <unistd.h>
#if (defined(LINUX) || defined(__linux__))
#include <linux/limits.h>
#else
#include <sys/syslimits.h>
#endif
/* Vala doesn't have this, for some reason... */
gchar *vala_getcwd(void) {
    char cwd[PATH_MAX];
    return getcwd(cwd, 256);
}