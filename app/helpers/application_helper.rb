module ApplicationHelper
  def render_markdown(text)
    return "" if text.blank?
    
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      no_images: false,
      no_links: false,
      safe_links_only: false,
      hard_wrap: true,
      prettify: true
    )
    
    markdown = Redcarpet::Markdown.new(renderer, {
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      autolink: true,
      strikethrough: true,
      lax_html_blocks: true,
      superscript: true,
      tables: true
    })
    
    markdown.render(text).html_safe
  end
end
