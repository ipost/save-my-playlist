require 'json'
outfile_name = ARGV[0] || fail("Usage: ruby #{__FILE__} output_filename")
list = Dir.chdir('data') do
  files = Dir['*'].select { |f| f[/^\d+$/] || f[/^\d+\.json$/] }
  files.each do |f|
    print "\x08" * 99 + "Processing #{f}..."
    JSON.parse(File.read(f)).reduce({}) do |videos, v|
      id, title = if v['content_details']
                    [v['content_details']['id'], v['snippet']['title']]
                  elsif v['id']
                    [v['id'], v['title']]
                  else
                    fail
                  end
      videos[id] = title unless videos[id]
      videos
    end
  end
end
File.write(outfile_name, JSON.pretty_generate(list))
