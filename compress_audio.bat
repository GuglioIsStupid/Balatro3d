for %%f in (*.ogg) do ffmpeg -i "%%f" -c:a libopus -b:a 64k -strict -2 "%%f"
