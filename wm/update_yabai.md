1. ```yabai --stop-service```
1. ```arch -arm64 brew upgrade yabai```
1. ```yabai --start-service```
1. ```sudo visudo -f /private/etc/sudoers.d/yabai```
1. <user> ALL=(root) NOPASSWD: sha256:<hash> <yabai> --load-sa
    - shasum -a 256 $(which yabai) ➡ \<hash>️
1. ```yabai --restart-service```
