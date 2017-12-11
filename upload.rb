require 'google_drive'
s = GoogleDrive::Session.from_config('config.json')
file_name = ARGV[0] || fail("Usage: ruby #{__FILE__} filename")
s.upload_from_file(file_name)
s.files.select { |f| f.name == file_name }.sort_by(&:modified_time)[0..-2].each(&:delete)
puts "#{file_name} uploaded successfully"
