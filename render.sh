#!/bin/bash

# configure the bot
python3 -m simplebot init "$ADDR" "$PASSWORD"
python3 -m simplebot -a "$ADDR" set_name "$BOTNAME"
python3 -m simplebot -a "$ADDR" db -s "simplebot_instantview/max_size" "15728640"  # 15MB
python3 -m simplebot -a "$ADDR" db -s "simplebot_downloader/mode" "command"
python3 -m simplebot -a "$ADDR" db -s "simplebot_downloader/max_size" "1073741824"  # 1GB
python3 -m simplebot -a "$ADDR" db -s "simplebot_downloader/delay" $DELAY
python3 -m simplebot -a "$ADDR" db -s "simplebot_translator/filter_enabled" "no"
python3 ./restore_keys.py


# add simple web server for service healthy 
python3 -m simplebot -a "$ADDR" plugin --add ./simplebot_render.py

# add the bing plugin
python3 -c "import requests; r=requests.get('https://github.com/nelson9608/simplebot-scripts/raw/master/scripts/bing.py'); open('bing.py', 'wb').write(r.content)"
python3 -m simplebot -a "$ADDR" plugin --add ./bing.py


# add the encryption_error plugin to leverage key changes
python3 -c "import requests; r=requests.get('https://github.com/adbenitez/simplebot-scripts/raw/master/scripts/encryption_error.py'); open('encryption_error.py', 'wb').write(r.content)"
python3 -m simplebot -a "$ADDR" plugin --add ./encryption_error.py

# add admin plugin
if [ -n "$ADMIN" ]; then
    python3 -c "import requests; r=requests.get('https://github.com/adbenitez/simplebot-scripts/raw/master/scripts/admin.py'); open('admin.py', 'wb').write(r.content)"
    python3 -m simplebot -a "$ADDR" plugin --add ./admin.py
    python3 -m simplebot -a "$ADDR" admin --add "$ADMIN"
fi

# start the bot
python3 -m simplebot -a "$ADDR" serve
