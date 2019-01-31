FROM selenium/standalone-chrome-debug:3.141.59-dubnium

# Update chrome
RUN sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && sudo apt-get update \
    && sudo apt-get --only-upgrade install google-chrome-stable \
    && sudo rm /etc/apt/sources.list.d/google-chrome.list \
    && sudo /opt/bin/wrap_chrome_binary