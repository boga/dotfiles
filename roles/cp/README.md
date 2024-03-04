CP
=========

Role Variables
--------------

### Variables:

| Name                  | Description                                                          | Default value                      |
|-----------------------|----------------------------------------------------------------------|------------------------------------|
| cp_entity_destination | Destination of the file, i.e. `~/.config/wezterm/wezterm.lua`        |                                    |
| cp_entity_source      | Source of the file, i.e. `./templates/wezterm.lua.j2`                |                                    |
| cp_entity_name        | Human readable name for en entity to improve run readability         |                                    |
| cp_entity_owner       | User name of the owner of the file as per `chown`                    | `ansible_user` from the inventory  |
| cp_entity_group       | Group name of the owner of the file as per `chown`                   | `ansible_group` from the inventory |
| cp_entity_permissions | Permissions of the resulting file as per `chmod`                     | `0600`                             |
