class UpdateVersionsCollation < ActiveRecord::Migration[8.0]
  def up
    # Versions table is currently using utf8mb4_general_ci collation
    # We are changing it to utf8mb4_0900_ai_ci to match other tables
    # fixes: https://github.com/UMN-LATIS/z/issues/266
    execute <<-SQL
      ALTER TABLE versions 
      CONVERT TO CHARACTER SET utf8mb4 
      COLLATE utf8mb4_0900_ai_ci
    SQL
  end

  def down
    # Rollback to original collation if needed
    execute <<-SQL
      ALTER TABLE versions 
      CONVERT TO CHARACTER SET utf8mb4 
      COLLATE utf8mb4_general_ci
    SQL
  end
end