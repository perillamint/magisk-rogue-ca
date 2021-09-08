# Rogue CA magisk module builder

## About

To reverse-engineer the Android app, you often have to launch a MitM
attack between the victim app and its server. However, in most cases,
the app only trusts system certificate storage. To overcome this,
the user has to install the certificate in /system partiton.

This tool makes those tasks easy to use, easy to set up.

## How to use

Run following commands

```
./gen_ca.sh
./package.sh
```

And load zip file on your victim device.

## Use with mitmproxy

Run

```
./setup_mitmproxy.sh
```

and it will install generated rogue certificate into ~/.mitmproxy
