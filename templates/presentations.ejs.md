```{=html}
<%

const now = new Date();

const dateOptions = {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
};

function formatDate(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return isNaN(d.getTime()) ? dateStr : d.toLocaleDateString('en-GB', dateOptions);
}

// Split items into upcoming and past
const upcomingItems = [];
const pastItems = [];

items.forEach(function(item) {
  const itemDate = item.date ? new Date(item.date) : null;
  if (itemDate && itemDate >= now) {
    upcomingItems.push(item);
  } else {
    pastItems.push(item);
  }
});

// Sort upcoming items ascending (soonest first)
upcomingItems.sort((a, b) => new Date(a.date) - new Date(b.date));

// Sort past items descending (most recent first)
pastItems.sort((a, b) => new Date(b.date) - new Date(a.date));

function renderItem(item, showTime = false) { %>
  <div class="row align-items-center py-3 border-bottom listing-item">
    <div class="col-md-4 text-secondary">
      <% if (item.date) { %>
        <div><%= formatDate(item.date) %></div>
      <% } 
         if (item.time && showTime) { %>
         <div><%= item.time %></div>
      <% }
         if (item.venue && item.venueLink) { %>
         <a href="<%= item.venueLink %>" class="mt-1"><%= item.venue %></a>
      <% } else if (item.venue) { %>
         <div class="mt-1"><%= item.venue %></div>
      <% } %>
    </div>

    <div class="col-md-8">
      <h3>
        <% if (item.slides) { %>
          <a href="<%= item.slides %>" target="_blank" rel="noop noreferrer"><%= item.title %></a>
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

<div>

  <section class="mb-5">
    <h2 class="h2 text-primary border-bottom pb-2 mb-3">Upcoming</h2>
    <% if (upcomingItems.length > 0) { %>
      <div class="list">
        <% upcomingItems.forEach(item => renderItem(item, true)); %>
      </div>
    <% } else { %>
      <p class="text-muted">No upcoming presentations</p>
    <% } %>
  </section>

  <section class="mb-5">
    <h2 class="h2 text-primary border-bottom pb-2 mb-3">Past</h2>
    <div class="list">
      <% pastItems.forEach(item => renderItem(item, false)); %>
    </div>
  </section>

</div>
```
