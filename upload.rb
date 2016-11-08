require 'google_drive'
s = GoogleDrive::Session.from_config('config.json')
file_name = 'playlist_backups.tar.gz'
`tar -cvzf #{file_name} data`
s.upload_from_file(file_name)
`rm #{file_name}`
s.files.select { |f| f.name == file_name }.sort_by(&:modified_time)[0..-2].each(&:delete)
puts "#{file_name} uploaded successfully"
