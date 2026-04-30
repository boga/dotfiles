Config Files
============

Copies a list of templated configuration files to their destination paths.

Role Variables
--------------

| Name | Description | Default |
|------|-------------|---------|
| `config_files_items` | List of config file definitions. Each item supports `name`, `src`, `dest`, and optional `permissions`, `owner`, `group`. | `[]` |
| `config_files_permissions` | Default file permissions. | `0600` |
| `config_files_owner` | Default file owner. | `ansible_user` |
| `config_files_group` | Default file group. | `ansible_group` |

Example
-------

```yaml
- ansible.builtin.include_role:
    name: config_files
  vars:
    config_files_items: "{{ config_files }}"
```
