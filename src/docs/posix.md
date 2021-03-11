# POSIX Shell Script

Mostly learned from [shellcheck](https://github.com/koalaman/shellcheck).

## Utils

Usefull utils:

| name   | function                                        |
| ------ | ----------------------------------------------- |
| numfmt | Convert numbers from/to human-read‐able strings |
| paste  | merge lines of file                             |
| printf | format and print data                           |

## Convert bytes to string with unit

```shell
printf "%4sB" "$(numfmt --to=iec 125829120)"
```

## Check if file exists

```shell
if [ -f "$FILE" ]
then
  echo "$FILE exists."
fi
```

## Check if command exists

```shell
if command -v COMMAND > /dev/null
then
  echo "command exists"
fi
```

## Check if function has an argument

```shell
if [ "$#" -ne 0 ]
then
  echo "has argument"
fi
```

## Check if string contains substring

```shell
if [ "$#" -ne 0 ]
then
  echo "has argument"
fi
```
