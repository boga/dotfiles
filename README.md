The inventory file is required:
```yaml
all:
  hosts:
    some_host:
      ansible_host: localhost
      ansible_connection: local
      ansible_user: here-comes-username
      ansible_group: of-people
      # If using Homebrew Ansible, pin the interpreter to avoid discovery issues.
      # Example for Intel Homebrew:
      ansible_python_interpreter: /usr/local/bin/python3.14
  vars:
    # Replacement for the deprecated DEFAULT_MANAGED_STR option.
    # Uses template context instead of {file}/{uid}/{host} placeholders.
    ansible_managed: "Ansible managed: {{ template_path }} modified on {{ ansible_date_time.iso8601 }} by {{ ansible_user_id }} on {{ inventory_hostname }}"
```
