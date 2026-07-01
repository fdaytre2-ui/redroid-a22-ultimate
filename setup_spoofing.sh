#!/system/bin/sh

# 1. إعداد LD_PRELOAD للخدمات الرئيسية (عبر setprop)
setprop wrap.com.android.zygote "LD_PRELOAD=/system/lib64/libspoof.so"
setprop wrap.com.android.systemui "LD_PRELOAD=/system/lib64/libspoof.so"
# إعادة تشغيل الـ zygote ليحمل المكتبة
kill -HUP $(pgrep -f zygote) 2>/dev/null || true

# 2. إعداد ملفات البطارية الوهمية (لأن LD_PRELOAD سيعترض fopen/open)
mkdir -p /data/local/tmp/fake_battery
echo "85" > /data/local/tmp/fake_battery/capacity
echo "Discharging" > /data/local/tmp/fake_battery/status

# 3. توليد IMEI عشوائي وتثبيته
IMEI=$(cat /dev/urandom | tr -dc '0-9' | fold -w 15 | head -n 1)
setprop persist.radio.device.imei $IMEI
setprop ro.ril.oem.imei $IMEI

# 4. توليد Android ID و Serial عشوائي
AID=$(openssl rand -hex 16)
settings put secure android_id $AID
SERIAL=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 12 | head -n 1)
setprop ro.serialno $SERIAL

# 5. تزوير إشارة الشبكة
setprop gsm.signal.strength 31
setprop gsm.network.type "LTE"
setprop gsm.operator.alpha "Vodafone"
setprop gsm.operator.numeric "20201"
