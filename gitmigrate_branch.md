# Git migrate codes

To migrate code from repo `xyz` to `abc` use the following.

```sh
git clone https://github.com/xyz/xyz.git
cd xyz
git branch -r | grep -v '\->' | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
git fetch --all
git pull --all
git remote remove origin
git remote add origin git@github.com:abc/abc.git
git push --all origin
cd ..
```
