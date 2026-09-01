```{=html}
<%

items.sort((a, b) => b.year - a.year);

%>

<div class="list">
  <% for (const item of items) { %>
  <div class="row align-items-center py-3 border-bottom listing-item">
    <div class="col-md-4 text-secondary">
      <% if (item.year) { %>
        <div><%= item.year %></div>
      <% } %>
      <% if (item.venue && item.venueLink) { %>
         <a href="<%= item.venueLink %>" class="mt-1"><%= item.venue %></a>
      <% } else if (item.venue) { %>
         <div class="mt-1"><%= item.venue %></div>
      <% } %>
    </div>

    <div class="col-md-8">
      <h3>
        <% if (item.pdf) { %>
          <a href="<%= item.pdf %>" target="_blank" rel="noop noreferrer"><%= item.title %></a>
        <% } else { %>
          <%= item.title %>
        <% } %>
      </h3>
      <% if (item.abstract) { %>
      <p class="small text-muted"><%= item.abstract %></p>
      <% } %>
    </div>
  </div>
  <% } %>
</div>
```
