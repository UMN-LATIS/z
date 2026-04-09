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
      if value.match?(/\A"(.+)"\z/)
        # Escape _ so it matches literally (not as a single-char wildcard).
        # We keep % unescaped so power users can do e.g. "abc%xyz".
        # This is why we use `matches` (LIKE) instead of `eq` (=).
        pattern = value.delete_prefix('"').delete_suffix('"').gsub("_", "\\_")
        column.table[column.field].matches(pattern)
      else
        column.table[column.field].matches("%#{value}%")
      end
    }
  end
end
