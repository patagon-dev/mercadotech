Deface::Override.new(
  virtual_path: 'spree/admin/images/edit',
  name: 'add_s3_persisted_url_to_image_edit',
  replace: 'div[data-hook="thumbnail"]',
  text: <<-HTML
                <div data-hook="thumbnail" class="col-12 col-lg-3 text-center">
                  <%= f.label Spree.t(:thumbnail) %>
                  <%= link_to image_tag(s3_persisted_url(@image.url(:small), true)), s3_persisted_url(@image.attachment) %>
                </div>
  HTML
)

Deface::Override.new(
  virtual_path: 'spree/admin/images/index',
  name: 'add_s3_persisted_url_to_image_index',
  replace: 'td.image',
  text: <<-HTML
                <td class="image">
                 <%= link_to image_tag(s3_persisted_url(image.url(:mini), true)), s3_persisted_url(image.attachment) %>
                </td>
  HTML
)
