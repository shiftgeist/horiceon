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
