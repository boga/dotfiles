{% raw %}---
name: new-relic
description: Query New Relic (NR) observability data. Use when the user asks about dashboards, metrics, alerts, logs, incidents, deployments, NRQL queries, synthetic monitors, or anything related to NR / New Relic.
---

# New Relic (NR)

Query New Relic observability data via MCP tools. The NR MCP server is pre-configured.

## Account ID

Read the account ID from the environment before every tool call:

```bash
echo $NEW_RELIC_MCP_ACCOUNT_ID
```

Pass the value as `account_id` to all tools. If the variable is unset or empty, call `new_relic_list_available_new_relic_accounts` (no parameters) and ask the user to pick an account.

## Tool Selection

| Intent | Tool |
|--------|------|
| List dashboards | `new_relic_list_dashboards` → `new_relic_get_dashboard` for detail |
| Run NRQL query | `new_relic_execute_nrql_query` |
| Natural language query | `new_relic_natural_language_to_nrql_query` |
| Find entities / apps | `new_relic_get_entity` |
| Recent alerts / incidents | `new_relic_list_recent_issues` |
| Alert policies | `new_relic_list_alert_policies` |
| Logs | `new_relic_list_recent_logs` |
| Synthetic monitors | `new_relic_list_synthetic_monitors` |
| Deployment impact | `new_relic_analyze_deployment_impact` |
| Alert insights report | `new_relic_generate_alert_insights_report` |
| User impact report | `new_relic_generate_user_impact_report` |

## Entity GUIDs

Many tools require `entity_guid`. Discover it first:

```
new_relic_get_entity(name_pattern="my-service", domains=["APM"], types=["APPLICATION"])
```

Each result includes `guid` and `accountId`.

## Pagination

List tools return `has_more` and `next_cursor`. If `has_more` is true, pass the `next_cursor` value as `cursor` on the next call. Avoid `limit: -1` on large accounts — it may exceed token limits; use `limit: 10–25` and paginate instead.
{% endraw %}
