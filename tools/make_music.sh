#/bin/sh

# This script creates BoosterMusicBooks.zip and generates music_blank.ts
# License: same with Pianobooster
# Author: Alexey Loginov <alexl@mageia.org>

pushd ../

echo "Determining MUSIC_RELEASE..."
version=`cat src/Settings.cpp|grep 'MUSIC_RELEASE ='|cut -d "=" --fields=2|sed "s|.* ||g"|cut -d ";" --fields=1`
echo "Done for determining MUSIC_RELEASE"
echo "MUSIC_RELEASE=$version"

echo "Preparing temporary directory..."
rm -rf music/BoosterMusicBooks$version
echo "Done for preparing temporary directory"

echo "Creating subdirectories in temporary directory..."
mkdir -p music/BoosterMusicBooks$version/BeginnerCourse/InfoPages
mkdir -p music/BoosterMusicBooks$version/BoosterMusic/InfoPages
echo "Done for creating subdirectories in temporary directory"

echo "Copying MIDI files..."
cp -f doc/courses/BeginnerCourse/*.mid music/BoosterMusicBooks$version/BeginnerCourse/
cp -f doc/courses/BoosterMusic/*.mid music/BoosterMusicBooks$version/BoosterMusic/
echo "Done for copying MIDI files"

echo "Generating HTML files from MD files..."
for file in `find ./music-src -name ??-*.md`
do
  file_html=`echo $file|sed "s|_en.md|_en.html|g"|sed "s|./music-src|music/BoosterMusicBooks$version|g"|sed "s|/0|/InfoPages/0|g"`
  markdown $file > $file_html
  awk 'NR>1{printf "\n"} {printf $0}' $file_html > "$file_html"_tmp
  mv -f "$file_html"_tmp $file_html
  sed -i 's|<p><strong>Hint:|<font color="#ff0000"><p><b>Hint:|g' $file_html
  printf "</font>" >> $file_html
  printf "</body>" >> $file_html
  sed -i '1s/^/<body bgcolor="#FFFFC0">/' $file_html
done
echo "Done for generating HTML files from MD files"

echo "Creating ZIP file..."
pushd music
rm -f BoosterMusicBooks.zip
zip -r BoosterMusicBooks.zip BoosterMusicBooks$version
popd
echo "Done for creating ZIP file"

popd

echo "Generating music_blank.ts by conv_html_to_ts.pl..."
./conv_html_to_ts.pl ../music/BoosterMusicBooks$version
mv music_blank.ts ../translations/
echo "Done for generating music_blank.ts by conv_html_to_ts.pl"

echo "Deleting temporary directory..."
rm -rf ../music/BoosterMusicBooks$version
echo "Done for deleting temporary directory"