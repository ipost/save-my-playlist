pl_id = ARGV[0] || fail("No playlist id provided")
key = File.read('.api_key')

require 'fileutils'
require 'google/apis'
require 'google/apis/youtube_v3'

TIMESTAMP = '%Y%m%d%H%M%S'
Video = Struct.new(:snippet, :content_details)

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
  snips.zip(cds).map { |snip, cd| Video.new(snip, cd) }
end.flatten

data = videos.map { |v| { id: v.content_details.id, title: v.snippet.title } }
file_name = "data/#{Time.now.strftime(TIMESTAMP)}"
Dir.mkdir('data') unless Dir.exist?('data')
File.write(file_name, JSON.pretty_generate(data))
puts "Saved #{data.length} records to #{file_name}"
