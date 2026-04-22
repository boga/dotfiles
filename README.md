Because both inventory entries target `localhost`, you should limit each run to the laptop you are currently on. This ensures Ansible loads the correct host-specific variables:

```bash
ansible-playbook -i inventory.yml site.yml --limit home
ansible-playbook -i inventory.yml site.yml --limit work
```
