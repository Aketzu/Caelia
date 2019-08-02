
# Timelapse generation

 (echo "ffconcat version 1.0"; (for f in $(find $(pwd)); do echo "file" $f; done | grep JPG | sort)) > timelapse.ffcat

 ffmpeg -r 30 -safe 0 -i timelapse.ffcat -vf crop=3000:1688:0:100,scale=1920:1080 -vcodec libx264 -preset slow -an -x264opts crf=18 -y timelapse-ke.mp4
                                                              ^ vary crop position

# ffmpeg compilation
```
--- a/ffmpeg-dmo-4.1.4/debian/rules       2019-07-10 08:44:38.000000000 +0300
+++ b/ffmpeg-dmo-4.1.4/debian/rules       2019-07-31 20:23:07.993165228 +0300
@@ -37,6 +37,8 @@
        --disable-gnutls \
        --enable-openssl \
        --enable-gpl \
+       --enable-cuda-sdk --enable-cuvid --enable-nvenc --enable-nonfree --enable-libnpp \
+       --enable-libndi_newtek \
        --enable-libass \
        --enable-libbluray \
        --enable-libbs2b \
@@ -215,6 +217,8 @@
 override_dh_installdocs:
        dh_installdocs -A RELEASE_NOTES MAINTAINERS

+override_dh_shlibdeps:
+       dh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info
 #override_dh_strip:

 override_dh_dwz override_dh_auto_install override_dh_auto_clean override_dh_auto_test override_dh_prep:
```

# .netrc
```
machine pms.ikikier.io
login asmapi
password x
```
