#Zoneminder
Built from PPA

##Tips and Setup Instructions:
- This container includes mysql, no need for a separate mysql/mariadb container
- All settings are stored in the mysql database, and that is stored outside of the container and they are preserved when this docker is updated or re-installed (change the variable "/path/to/config" in the run command to a location of your choice)

### Mandatory settings
- In the WebUI, click on Options in the top right corner. Go to the "paths" tab.
- update PATH_ZMS to /zm/cgi-bin/nph-zms

### Optimal settings
- Next, go to the Images tab
- This container includes avconv (ffmpeg variant) but it needs to be enabled in the settings. 
- Click on the box next OPT_FFMPEG to enable ffmpeg
- Enter the following for PATH_FFMPEG: /usr/bin/avconv
- Enter the following for fFFMPEG_OUTPUT_OPTIONS: -r 30 -vcodec libx264 -threads 2 -b 2000k -minrate 800k -maxrate 5000k (you can change these options to your liking)
- in FFMPEG_FORMATS, add mp4 (you can also add a star after mp4 and remove the star after avi to make mp4 the default format)
- I also like to set MPEG_LIVE_FORMAT and MPEG_REPLAY_FORMAT to "webm" to allow streaming on chrome without flash
- Hit save
- Now you should be able to add your cams and record in mp4 x264 format
- PS. In options under display, change the skin to "flat" it looks 100 times nicer

thanks to https://hub.docker.com/r/aptalca/docker-zoneminder/ for the inspiration and some of the methods i used in the early stages of this docker
