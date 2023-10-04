#!/bin/sh

# convert images in directory to webp

ls $1 | parallel cwebp -short {} -o {.}.webp
