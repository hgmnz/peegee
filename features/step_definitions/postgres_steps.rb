Then /^the "(\w+)" table should have the following index(?:es)?:$/ do |table_name, indexes|
  actual_indexes = select_all(<<-INDEX_SQL).map { |r| r["index_def"] }
    SELECT pg_catalog.pg_get_indexdef(i.indexrelid, 0, true) as index_def
    FROM pg_catalog.pg_class c, pg_catalog.pg_class c2, pg_catalog.pg_index i
    WHERE c.oid = '#{oid(table_name)}' AND c.oid = i.indrelid AND i.indexrelid = c2.oid
  INDEX_SQL
  actual_indexes.should include(*indexes.raw.flatten)
end
