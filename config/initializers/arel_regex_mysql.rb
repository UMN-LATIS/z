# This works around the fact that, as of 4-28-17, that Arel does not support
# regex for MySQL. This code is taking from an outstanding pull request
# (one year old at the time of this comment). Once this pull request is officially
# merged and Arel is updated, then this file can be removed.
# https://github.com/rails/arel/pull/286
module Arel
  module Visitors
    class MySQL < Arel::Visitors::ToSql
      private

      # rubocop:disable Naming/MethodName

      def visit_Arel_Nodes_Regexp(obj, collector)
        infix_value obj, collector, ' REGEXP '
      end

      def visit_Arel_Nodes_NotRegexp(obj, collector)
        infix_value obj, collector, ' NOT REGEXP '
      end
      # rubocop:enable Naming/MethodName
    end
  end
end
