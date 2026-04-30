{% raw %}---
name: brave-search
description: Search the web using Brave Search API. Use when the user asks about current events, online resources, documentation, or anything requiring up-to-date information from the web.
---

# Brave Search

Search the web using the Brave Search API. The `BRAVE_SEARCH_API_KEY` environment variable is available.

## Search

```bash
curl -s \
  -H "X-Subscription-Token: $BRAVE_SEARCH_API_KEY" \
  -H "Accept: application/json" \
  "https://api.search.brave.com/res/v1/web/search?q=QUERY&count=5"
```

Replace `QUERY` with a URL-encoded search query. Adjust `count` (1–20) as needed.

The response is JSON. The relevant results are in `.web.results[]`, each with `title`, `url`, and `description` fields.
{% endraw %}
