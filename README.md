The inventory file is required. For multiple laptops that both run locally, keep both hosts in `inventory.yml` and put machine-specific values in `host_vars/`:

```yaml
all:
  hosts:
    home:
      ansible_host: localhost
      ansible_connection: local
    work:
      ansible_host: localhost
      ansible_connection: local
  vars:
    # Replacement for the deprecated DEFAULT_MANAGED_STR option.
    # Uses template context instead of {file}/{uid}/{host} placeholders.
    ansible_managed: "Ansible managed: {{ template_path }} modified on {{ ansible_facts[\"date_time\"][\"iso8601\"] }} by {{ ansible_facts[\"user_id\"] }} on {{ inventory_hostname }}"
```

Example `host_vars/home.yml`:

```yaml
ansible_user: here-comes-username
ansible_group: of-people
# If using Homebrew Ansible, pin the interpreter to avoid discovery issues.
# Example for Intel Homebrew:
ansible_python_interpreter: /usr/local/bin/python3.14
firefox_profile_dir: /Users/here-comes-username/Library/Application Support/Firefox/Profiles/some-profile.default-release
homebrew_packages:
  - ansible
  - ansible-lint
  - fd
  - fzf
```

Do the same for `host_vars/work.yml`, starting from the same package list and then adjusting per machine.

Because both inventory hosts point at `localhost`, run the playbook with a host limit so Ansible only applies the current machine's vars:

```bash
ansible-playbook -i inventory.yml site.yml --limit home
ansible-playbook -i inventory.yml site.yml --limit work
```

There is not a built-in Ansible environment variable equivalent to `--limit`, but you can absolutely use your own shell variable as a shortcut:

```bash
LAPTOP=home ansible-playbook -i inventory.yml site.yml --limit "$LAPTOP"
```

Or set it in your shell profile:

```bash
export LAPTOP=home
ansible-playbook -i inventory.yml site.yml --limit "$LAPTOP"
```
