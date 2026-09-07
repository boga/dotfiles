# Config Files

Copies a list of rendered or raw configuration files and directories to their destination paths.

## Role Variables

| Name                       | Description                                                                                               | Default        |
|----------------------------|-----------------------------------------------------------------------------------------------------------|----------------|
| `config_files_items`       | Config definitions with `name`, `src`, `dest`, and optional `permissions`, `owner`, `group`, `render`.    | `[]`           |
| `config_files_permissions` | Default file permissions.                                                                                 | `0600`         |
| `config_files_owner`       | Default file owner.                                                                                       | `ansible_user` |
| `config_files_group`       | Default file group.                                                                                       | `ansible_group` |
| `render`                   | Per-item flag. Set `false` to copy content without Jinja rendering.                                      | `true`         |

## Example

```yaml
- ansible.builtin.include_role:
    name: config_files
  vars:
    config_files_items: "{{ config_files }}"
```

## Raw Files and Directories

Set `render: false` for content that must not pass through Jinja, including directories containing Helm templates or other literal `{{ }}` syntax.
