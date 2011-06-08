Given /^I implement the latest migration as:$/ do |implementation|
  in_current_dir do
    migrations        = Dir["db/migrate/[0-9]*_*.rb"].sort.to_a
    path              = migrations.last
    contents          = IO.read(path)
    class_declaration = contents.split("\n").first
    new_contents      = "#{class_declaration}\n#{implementation}\nend"
    File.open(path, "w") { |file| file.write(new_contents) }
  end
end
