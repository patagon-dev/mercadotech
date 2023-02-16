Deface::Override.new(
  virtual_path: 'spree/admin/payments/_capture_events',
  name: 'display amount without cents in capture event',
  replace: 'tr[data-hook="capture_events_row"]',
  text: <<-HTML
                <tr id="<%= dom_id(capture_event) %>" data-hook="capture_events_row">
                  <td><%= pretty_time(capture_event.created_at) %></td>
                  <td><%= @payment.display_amount %></td>
                </tr>
  HTML
)
