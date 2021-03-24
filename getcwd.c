#include <glib.h>
#include <unistd.h>
/* Vala doesn't have this, for some reason... */
gchar *vala_getcwd(void) {
    char cwd[256];
    return getcwd(cwd, 256);
}