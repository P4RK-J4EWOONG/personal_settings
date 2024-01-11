# Updating Yabai

Follow these steps to update Yabai:

1. Stop the Yabai service:

    ```bash
    yabai --stop-service
    ```

2. Upgrade Yabai using Homebrew. Note that we're using the ARM64 architecture:

    ```bash
    arch -arm64 brew upgrade yabai
    ```

3. Start the Yabai service:

    ```bash
    yabai --start-service
    ```

4. Open the Yabai configuration file in the sudoers directory. This will require your administrator password:

    ```bash
    sudo visudo -f /private/etc/sudoers.d/yabai
    ```

5. Add the following line to the file, replacing `<user>` with your username, `<hash>` with the SHA-256 hash of the Yabai binary, and `<yabai>` with the path to the Yabai binary:

    ```bash
    <user> ALL=(root) NOPASSWD: sha256:<hash> <yabai> --load-sa
    ```

    - To get the SHA-256 hash of the Yabai binary, use the following command:

        ```bash
        shasum -a 256 $(which yabai)
        ```

6. Finally, restart the Yabai service:

    ```bash
    yabai --restart-service
    ```
