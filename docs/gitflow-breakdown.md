# Gitflow Breakdown

> A comparison of using `git flow` commands versus raw `git` commands.

By [James M. Greene](https://github.com/JamesMGreene)

## Connect to the remote repository

| gitflow | git                                                     |
| ------- | ------------------------------------------------------- |
| _N/A_   | `git remote add origin git@github.com:MYACCOUNT/MYREPO` |

## Features

### Create a feature branch

| gitflow                            | git                                         |
| ---------------------------------- | ------------------------------------------- |
| `git flow feature start MYFEATURE` | `git checkout -b feature/MYFEATURE develop` |

### Get latest for a feature branch

| gitflow                                  | git                                          |
| ---------------------------------------- | -------------------------------------------- |
| `git flow feature pull origin MYFEATURE` | `git checkout feature/MYFEATURE`             |
| &nbsp;                                   | `git pull --rebase origin feature/MYFEATURE` |

### Finalize a feature branch

| gitflow                             | git                                   |
| ----------------------------------- | ------------------------------------- |
| `git flow feature finish MYFEATURE` | `git checkout develop`                |
| &nbsp;                              | `git merge --no-ff feature/MYFEATURE` |
| &nbsp;                              | `git branch -d feature/MYFEATURE`     |

## Releases

### Create a release branch

| gitflow                        | git                                     |
| ------------------------------ | --------------------------------------- |
| `git flow release start 1.2.0` | `git checkout -b release/1.2.0 develop` |

### Get latest for a release branch

| gitflow | git                                      |
| ------- | ---------------------------------------- |
| _N/A_   | `git checkout release/1.2.0`             |
| &nbsp;  | `git pull --rebase origin release/1.2.0` |

### Finalize a release branch

| gitflow                         | git                               |
| ------------------------------- | --------------------------------- |
| `git flow release finish 1.2.0` | `git checkout master`             |
| &nbsp;                          | `git merge --no-ff release/1.2.0` |
| &nbsp;                          | `git tag -a 1.2.0`                |
| &nbsp;                          | `git checkout develop`            |
| &nbsp;                          | `git merge --no-ff release/1.2.0` |
| &nbsp;                          | `git branch -d release/1.2.0`     |

## Hotfixes

### Create a hotfix branch

| gitflow                                | git                                     |
| -------------------------------------- | --------------------------------------- |
| `git flow hotfix start 1.2.1 [commit]` | `git checkout -b hotfix/1.2.1 [commit]` |

### Finalize a hotfix branch

| gitflow                        | git                              |
| ------------------------------ | -------------------------------- |
| `git flow hotfix finish 1.2.1` | `git checkout master`            |
| &nbsp;                         | `git merge --no-ff hotfix/1.2.1` |
| &nbsp;                         | `git tag -a 1.2.1`               |
| &nbsp;                         | `git checkout develop`           |
| &nbsp;                         | `git merge --no-ff hotfix/1.2.1` |
| &nbsp;                         | `git branch -d hotfix/1.2.1`     |

## References

- http://nvie.com/posts/a-successful-git-branching-model/
- https://help.github.com/articles/using-pull-requests#shared-repository-model
- Personal experience
