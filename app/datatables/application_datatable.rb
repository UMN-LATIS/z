class ApplicationDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable
  attr_reader :view

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  # Returns a lambda for use as a custom :cond in view_columns.
  # Wrap a search term in double quotes for an exact match, e.g. "hello".
  # Without quotes, the default substring (LIKE %term%) match is used.
  def quoted_or_substring_match
    ->(column, value) {
      # Escape _ so it matches literally (not as a single-char wildcard).
      # We keep % unescaped so power users can do e.g. "abc%xyz".
      # This is why we use `matches` (LIKE) instead of `eq` (=).
      escaped = value.gsub("_", "\\_")

      if escaped.match?(/\A"(.+)"\z/)
        quoted = escaped.delete_prefix('"').delete_suffix('"')
        column.table[column.field].matches(quoted)
      else
        column.table[column.field].matches("%#{escaped}%")
      end
    }
  end
end
