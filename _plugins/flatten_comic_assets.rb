require "fileutils"

Jekyll::Hooks.register :site, :post_write do |site|
  comics_dir = File.join(site.dest, "assets", "comics")
  nested_files = Dir.glob(File.join(comics_dir, "**", "*"))
    .select { |path| File.file?(path) && File.dirname(path) != comics_dir }

  destinations = {}
  nested_files.each do |path|
    destination = File.join(comics_dir, File.basename(path))
    if File.exist?(destination) || destinations.key?(destination)
      raise Jekyll::Errors::FatalException,
            "Cannot flatten comic assets: multiple files named #{File.basename(path)}"
    end
    destinations[destination] = path
  end

  nested_files.each do |path|
    FileUtils.mv(path, File.join(comics_dir, File.basename(path)))
  end

  Dir.glob(File.join(comics_dir, "**", "*"))
    .select { |path| File.directory?(path) }
    .sort_by { |path| -path.length }
    .each { |path| Dir.rmdir(path) if Dir.empty?(path) }
end
