class ConvertGroupsAndUrlsToUtf8mb4 < ActiveRecord::Migration[8.1]
  def up
    return unless mysql?

    execute <<~SQL
      ALTER TABLE `groups`
      CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
    SQL

    execute <<~SQL
      ALTER TABLE `urls`
      CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
    SQL

    execute <<~SQL
      ALTER TABLE `groups`
      MODIFY `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
    SQL

    execute <<~SQL
      ALTER TABLE `groups`
      MODIFY `description` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
    SQL

    execute <<~SQL
      ALTER TABLE `urls`
      MODIFY `keyword` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
    SQL

    execute <<~SQL
      ALTER TABLE `urls`
      MODIFY `note` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
    SQL
  end

  def down
    return unless mysql?
    # Intentional no-op: reverting collations is environment-specific and
    # could reintroduce incompatibilities; handle explicitly if needed.
  end

  private

  def mysql?
    ActiveRecord::Base.connection.adapter_name.downcase.include?("mysql")
  end
end
