# POSIX Shell Script

Mostly learned from [shellcheck](https://github.com/koalaman/shellcheck).

## Utils

Usefull utils:

| name   | function                                        |
| ------ | ----------------------------------------------- |
| numfmt | Convert numbers from/to human-read‐able strings |
| paste  | merge lines of file                             |
| printf | format and print data                           |

## Convert

Bytes to string with unit

```shell
printf "%4sB" "$(numfmt --to=iec 125829120)"
```

Git url to folder name

```shell
basename "git@github.com:shiftgeist/horiceon.git" .git
```

## Check if...

Variable exists

```shell
if [ "$VARIABLE" ]
then
  echo "$VARIABLE is set."
fi
```

Variable is empty

```shell
if [ -z "$VARIABLE" ]
then
  echo "$VARIABLE is unset."
fi
```

Display exists

```shell
if [ "$DISPLAY" ]
then
  echo "No display attached."
else
  echo "Has display $DISPLAY."
fi
```

File exists

```shell
if [ -f "$FILE" ]
then
  echo "$FILE exists."
fi
```

Command exists

```shell
if command -v COMMAND > /dev/null
then
  echo "command exists"
fi
```

Function has an argument

```shell
if [ "$#" -ne 0 ]
then
  echo "has argument"
fi
```

String contains substring

```shell
if echo "hello world" | grep -q "world"
then
  echo "contains substring"
fi
```
