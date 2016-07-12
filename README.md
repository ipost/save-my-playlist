# save-my-playlist

I got tired of videos disappearing from my music playlist on Youtube and not knowing what went missing. So, I made this.

Put Google API key in ```.api_key```.

Call with ```ruby backup.rb {playlist_id}```. A timestamped file containing a JSON list of video ID/video title pairs will be placed in the ```data``` directory. Note, this does NOT save the videos themselves!

I recommend running it on a schedule using ```cron```.
