#!/system/bin/sh

# Namespace mount hack script from https://github.com/httptoolkit/httptoolkit-server/blob/965fd8d9b287af0e4b305d828d5e8e1aa52dce36/src/interceptors/android/adb-commands.ts#L298

# Deal with the APEX overrides in Android 14+, which need injecting into each namespace:
if [ -d "/apex/com.android.conscrypt/cacerts" ]; then
    echo 'Injecting certificates into APEX cacerts'
    # When the APEX manages cacerts, we need to mount them at that path too. We can't do
    # this globally as APEX mounts are namespaced per process, so we need to inject a
    # bind mount for this directory into every mount namespace.
    # First we get the Zygote process(es), which launch each app
    ZYGOTE_PID=$(pidof zygote || true)
    ZYGOTE64_PID=$(pidof zygote64 || true)
    # N.b. some devices appear to have both!
    # Apps inherit the Zygote's mounts at startup, so we inject here to ensure all newly
    # started apps will see these certs straight away:
    for Z_PID in "$ZYGOTE_PID $ZYGOTE64_PID"; do
        # We use 'echo' below to trim spaces
        nsenter --mount=/proc/$(echo $Z_PID)/ns/mnt -- \
            /bin/mount --rbind /system/etc/security/cacerts /apex/com.android.conscrypt/cacerts
    done
    echo 'Zygote APEX certificates remounted'
    # Then we inject the mount into all already running apps, so they see these certs immediately.
    # Get the PID of every process whose parent is one of the Zygotes:
    APP_PIDS=$(
        echo "$ZYGOTE_PID $ZYGOTE64_PID" | \
        xargs -n1 ps -o 'PID' -P | \
        grep -v PID
    )
    # Inject into the mount namespace of each of those apps:
    for PID in $APP_PIDS; do
        nsenter --mount=/proc/$PID/ns/mnt -- \
            /bin/mount --rbind /system/etc/security/cacerts /apex/com.android.conscrypt/cacerts &
    done
    wait # Launched in parallel - wait for completion here
    echo "APEX certificates remounted for $(echo $APP_PIDS | wc -w) apps"
fi
