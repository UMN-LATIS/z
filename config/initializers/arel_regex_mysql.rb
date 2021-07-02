# This works around the fact that, as of 4-28-17, that Arel does not support
# regex for MySQL. This code is taking from an outstanding pull request
# (one year old at the time of this comment). Once this pull request is officially
# merged and Arel is updated, then this file can be removed.
# https://github.com/rails/arel/pull/286
module Arel
  module Visitors
    class MySQL < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_Regexp o, collector
        infix_value o, collector, ' REGEXP '
      end

      def visit_Arel_Nodes_NotRegexp o, collector
        infix_value o, collector, ' NOT REGEXP '
      end
    end
  end
end
