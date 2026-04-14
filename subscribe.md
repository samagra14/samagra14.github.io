---
layout: page
title: Subscribe
permalink: /subscribe/
---

I write about ML infrastructure, building in the GPU era, and things worth thinking about. A few posts a month — no filler.

{% include newsletter-signup.html %}

---

### Via RSS

Paste either URL into any feed reader (Feedly, Reeder, NetNewsWire, Miniflux):

- **All posts** — `{{ '/feed.xml' | absolute_url }}`
- **Tech / ML infrastructure only** — `{{ '/feed/Tech.xml' | absolute_url }}`
- **Philosophy / essays only** — `{{ '/feed/Philosophy.xml' | absolute_url }}`

---

### Recent posts

{% assign recent = site.posts | limit: 5 %}
{% for post in recent %}
- [{{ post.title }}]({{ post.url | relative_url }}) — {{ post.date | date: "%b %Y" }}
{% endfor %}
