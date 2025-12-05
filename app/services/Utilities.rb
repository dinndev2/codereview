class Utilities
  MAX_TOTAL_CHANGES = 500
  MAX_FILE_CHANGES = 100

  def self.pr_too_big?(files)
    total_changes = files.sum { |f| f.changes.to_i }
    return true if total_changes > MAX_TOTAL_CHANGES
    files.any? { |f| f.changes.to_i > MAX_FILE_CHANGES }
  end
end