for %%f in (*.ogg) do ffmpeg -i "%%f" -c:a libopus -b:a 64k "%%~nf_compressed.ogg" && move /Y "%%~nf_compressed.ogg" "%%f"
