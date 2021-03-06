
pl_id = ARGV[0] || (puts("No playlist id provided"); exit(1))
key = File.read('.api_key').chomp

require 'fileutils'
require 'google/apis'
require 'google/apis/youtube_v3'

TIMESTAMP = '%Y%m%d%H%M%S'

api = Google::Apis::YoutubeV3::YouTubeService.new
api.key = key

response = api.list_playlist_items(:content_details, playlist_id: pl_id, max_results: 50)
playlist_items = response.items
while response.next_page_token
  response = api.list_playlist_items(:content_details, playlist_id: pl_id, max_results: 50, page_token: response.next_page_token)
  playlist_items += response.items
end

video_ids = playlist_items.map(&:content_details).map(&:video_id)

videos = video_ids.each_slice(50).map { |ids| ids.join(',') }.map do |ids|
  snips = api.list_videos(:snippet, id: ids).items.map(&:snippet)
  cds = api.list_videos(:content_details, id: ids).items
  snips.zip(cds).map { |snip, cd| {snippet: snip, content_details: cd} }
end.flatten

file_name = "data/#{Time.now.strftime(TIMESTAMP)}.json"
homemade_json = JSON.pretty_generate(JSON.parse('[' + videos.map do |v|
  "{\"snippet\": #{v[:snippet].to_json}, \"content_details\": #{v[:content_details].to_json}}"
end.join(',') + ']'))
Dir.mkdir('data') unless Dir.exist?('data')
File.write(file_name, homemade_json)
puts "Saved #{videos.length} records to #{file_name}"
