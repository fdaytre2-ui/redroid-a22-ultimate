#define _GNU_SOURCE
#include <dlfcn.h>
#include <string.h>
#include <fcntl.h>
#include <stdio.h>

// اعتراض open و openat
int open(const char *pathname, int flags, ...) {
    static int (*orig_open)(const char*, int, ...) = NULL;
    if (!orig_open) orig_open = dlsym(RTLD_NEXT, "open");
    if (strcmp(pathname, "/proc/cpuinfo") == 0)
        return orig_open("/system/etc/fake_cpuinfo", flags);
    if (strcmp(pathname, "/sys/class/power_supply/battery/capacity") == 0)
        return orig_open("/data/local/tmp/fake_battery/capacity", flags);
    if (strcmp(pathname, "/sys/class/power_supply/battery/status") == 0)
        return orig_open("/data/local/tmp/fake_battery/status", flags);
    return orig_open(pathname, flags);
}

int openat(int dirfd, const char *pathname, int flags, ...) {
    static int (*orig_openat)(int, const char*, int, ...) = NULL;
    if (!orig_openat) orig_openat = dlsym(RTLD_NEXT, "openat");
    if (strcmp(pathname, "/proc/cpuinfo") == 0)
        return orig_openat(dirfd, "/system/etc/fake_cpuinfo", flags);
    return orig_openat(dirfd, pathname, flags);
}

// اعتراض fopen
FILE *fopen(const char *pathname, const char *mode) {
    static FILE* (*orig_fopen)(const char*, const char*) = NULL;
    if (!orig_fopen) orig_fopen = dlsym(RTLD_NEXT, "fopen");
    if (strcmp(pathname, "/proc/cpuinfo") == 0)
        return orig_fopen("/system/etc/fake_cpuinfo", mode);
    if (strcmp(pathname, "/sys/class/power_supply/battery/capacity") == 0)
        return orig_fopen("/data/local/tmp/fake_battery/capacity", mode);
    return orig_fopen(pathname, mode);
}
