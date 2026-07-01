# المرحلة 1: بناء مكتبة التزوير (spoof.so) على لينكس
FROM arm64v8/ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y gcc libc6-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY spoof.c .
RUN gcc -shared -fPIC spoof.c -o libspoof.so -ldl

# المرحلة 2: صورة Redroid النهائية
FROM fahaddz/redroid:13-arm-pi5

# نسخ المكتبة من مرحلة البناء
COPY --from=builder /build/libspoof.so /system/lib64/libspoof.so

# نسخ ملفات التزوير
COPY samsung_a22_props.txt /system/build.prop
COPY samsung_a22_props.txt /vendor/build.prop
COPY samsung_a22_props.txt /product/build.prop
COPY samsung_a22_props.txt /odm/build.prop

# تزوير الـ HALs و GPU
RUN ln -sf /vendor/lib64/hw/gralloc.redroid.so /vendor/lib64/hw/gralloc.mt6769.so && \
    ln -sf /vendor/lib/hw/gralloc.redroid.so /vendor/lib/hw/gralloc.mt6769.so && \
    ln -sf /vendor/lib64/hw/hwcomposer.redroid.so /vendor/lib64/hw/hwcomposer.mt6769.so && \
    ln -sf /vendor/lib/hw/hwcomposer.redroid.so /vendor/lib/hw/hwcomposer.mt6769.so

RUN mkdir -p /vendor/lib/egl && mkdir -p /vendor/lib64/egl && \
    ln -sf /vendor/lib64/egl/libEGL_emulation.so /vendor/lib64/egl/libGLES_mali.so && \
    ln -sf /vendor/lib/egl/libEGL_emulation.so /vendor/lib/egl/libGLES_mali.so

# نسخ باقي الملفات
COPY fake_cpuinfo /system/etc/fake_cpuinfo
COPY setup_spoofing.sh /system/bin/setup_spoofing.sh
RUN chmod +x /system/bin/setup_spoofing.sh

ENTRYPOINT ["/init"]
