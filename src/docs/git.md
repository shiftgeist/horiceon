# git

<!-- https://devhints.io/git-tricks -->

## branch

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
