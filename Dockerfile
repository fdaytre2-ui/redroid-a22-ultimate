# استخدام الصورة الجاهزة التي تحتوي على Magisk و GApps (Kitsune Mask)
FROM fahaddz/redroid:13-arm-pi5

# تثبيت أدوات البناء لعمل مكتبة الـ LD_PRELOAD
RUN apt-get update && apt-get install -y gcc libc6-dev && rm -rf /var/lib/apt/lists/*

# 1. نسخ ملفات build.prop الخاصة بـ Samsung A22 (تزوير الهوية)
COPY samsung_a22_props.txt /system/build.prop
COPY samsung_a22_props.txt /vendor/build.prop
COPY samsung_a22_props.txt /product/build.prop
COPY samsung_a22_props.txt /odm/build.prop

# 2. بناء مكتبة التزوير (spoof.so) لاعتراض open/fopen
COPY spoof.c /tmp/spoof.c
RUN gcc -shared -fPIC /tmp/spoof.c -o /system/lib64/libspoof.so -ldl

# 3. عمل روابط رمزية للـ HALs لكي تظهر كـ Mediatek mt6769
RUN ln -sf /vendor/lib64/hw/gralloc.redroid.so /vendor/lib64/hw/gralloc.mt6769.so && \
    ln -sf /vendor/lib/hw/gralloc.redroid.so /vendor/lib/hw/gralloc.mt6769.so && \
    ln -sf /vendor/lib64/hw/hwcomposer.redroid.so /vendor/lib64/hw/hwcomposer.mt6769.so && \
    ln -sf /vendor/lib/hw/hwcomposer.redroid.so /vendor/lib/hw/hwcomposer.mt6769.so

# 4. تزوير الـ GPU (Mali-G52)
RUN mkdir -p /vendor/lib/egl && mkdir -p /vendor/lib64/egl && \
    ln -sf /vendor/lib64/egl/libEGL_emulation.so /vendor/lib64/egl/libGLES_mali.so && \
    ln -sf /vendor/lib/egl/libEGL_emulation.so /vendor/lib/egl/libGLES_mali.so

# 5. نسخ ملف cpuinfo الوهمي وسكريبت التشغيل
COPY fake_cpuinfo /system/etc/fake_cpuinfo
COPY setup_spoofing.sh /system/bin/setup_spoofing.sh
RUN chmod +x /system/bin/setup_spoofing.sh

# نقطة الدخول (حسب الصورة الأصلية، لا تغيير)
ENTRYPOINT ["/init"]
