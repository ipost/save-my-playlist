#require 'pry'
require 'fileutils'
require 'google/apis'
require 'google/apis/youtube_v3'

TIMESTAMP = '%Y%m%d%H%M%S'
Video = Struct.new(:snippet, :content_details)

key = File.read('.api_key')
pl_id = ARGV[0] || fail("No playlist id provided")
s = Google::Apis::YoutubeV3::YouTubeService.new
s.key = key

r = s.list_playlist_items(:content_details, playlist_id: pl_id, max_results: 50)
playlist_items = r.items
while r.next_page_token
  r = s.list_playlist_items(:content_details, playlist_id: pl_id, max_results: 50, page_token: r.next_page_token)
  playlist_items += r.items
end

video_ids = playlist_items.map(&:content_details).map(&:video_id)

videos = video_ids.each_slice(50).map { |ids| ids.join(',') }.map do |ids|
  snips = s.list_videos(:snippet, id: ids).items.map(&:snippet)
  cds = s.list_videos(:content_details, id: ids).items
  snips.zip(cds).map { |snip, cd| Video.new(snip, cd) }
end.flatten

data = videos.map { |v| { id: v.content_details.id, title: v.snippet.title } }
file_name = "data/#{Time.now.strftime(TIMESTAMP)}"
Dir.mkdir('data') unless Dir.exist?('data')
File.write(file_name, data.to_json)
puts "Saved #{data.length} records to #{file_name}"
