# Convert

## GIFs

Resize GIF (imagemagick)

```shell
convert -coalesce -resize x48 -deconstruct in.gif out.gif
```

Speedup GIF (imagemagick)

```shell
identify -verbose in.gif | grep Delay

convert -delay 1x30 in.gif out.gif
```
