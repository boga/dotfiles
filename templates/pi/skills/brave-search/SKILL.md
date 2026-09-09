{% raw %}---
name: brave-search
description: Search the web using Brave Search API. Use when the user asks about current events, online resources, documentation, or anything requiring up-to-date information from the web.
---

# Brave Search

Search the web using the Brave Search API. The `BRAVE_SEARCH_API_KEY` environment variable is
available inside the `ctx_execute` sandbox.

Do **not** use `curl` or `wget` — pi blocks both, and the raw JSON would flood context.
`ctx_fetch_and_index` cannot be used either: Brave authenticates with an `X-Subscription-Token`
header and that tool takes no headers.

## Search

```javascript
ctx_execute({
  language: "javascript",
  code: `
    const query = "QUERY";
    const count = 5; // 1-20
    try {
      const res = await fetch(
        "https://api.search.brave.com/res/v1/web/search?q=" +
          encodeURIComponent(query) + "&count=" + count,
        {
          headers: {
            "X-Subscription-Token": process.env.BRAVE_SEARCH_API_KEY,
            "Accept": "application/json",
          },
        },
      );
      if (!res.ok) {
        console.log("Brave search failed: HTTP " + res.status + " " + res.statusText);
      } else {
        const data = await res.json();
        const results = data.web?.results ?? [];
        console.log(results.length + " results for: " + query);
        for (const r of results) {
          console.log("\\n" + r.title + "\\n" + r.url + "\\n" + r.description);
        }
      }
    } catch (err) {
      console.log("Brave search error: " + (err?.message ?? String(err)));
    }
  `,
})
```

Replace `QUERY` with the search query — `encodeURIComponent` handles the escaping, so pass it raw.

Only what `console.log` prints reaches context; the full JSON response stays in the sandbox.
Each result in `.web.results[]` carries `title`, `url`, and `description`.

## Reading a result

Do not fetch a result URL with `curl`. Pass it to `ctx_fetch_and_index(url, source)` — no auth
header is needed for ordinary pages — then pull the relevant sections with `ctx_search(queries)`.
{% endraw %}
