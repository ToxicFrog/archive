TITLE=Cubik

# clean up old binaries
rm -rf bin; mkdir bin

# create .love file
git archive HEAD --format=zip > bin/"$TITLE.love"

# create windows binaries
pushd bin
	cp -r ../love/win32 "$TITLE"
	cat "$TITLE/love.exe" "$TITLE.love" > "$TITLE"/"$TITLE.exe"
	rm "$TITLE/love.exe"
	zip -r "$TITLE-win32.zip" "$TITLE"
popd

# create OSX version
pushd bin
	cp -r ../love/love.app "$TITLE.app"
	cp "$TITLE.love" "$TITLE.app"/Contents/Resources/
	zip -r "$TITLE-osx.zip" "$TITLE.app"
popd

