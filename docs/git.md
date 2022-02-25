# git

<!-- https://devhints.io/git-tricks -->

push to remote

```
git push origin master
```

push to remote and save remote name as default

```
git push -u origin master
```

pull after forced update

```shell
git fetch

git reset origin/BRANCH --hard
```

checkout empty branch

```
git checkout --orphan BRANCH
```

rename branch

```
git checkout OLD
git branch -m NEW
git push origin -u NEW
git push origin --delete OLD
```

delete tag (local/remote)

```
git tag -d tagname

git push --delete origin tagname
```

## shell helper

get remote url

```shell
git ls-remote --get-url
```

get latest commit

```shell
git rev-list --tags --max-count=1
```

get latest tag

```shell
git describe --abbrev=0
```
