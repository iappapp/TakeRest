#!/bin/zsh
set -e
cd "$(dirname "$0")"

xcodebuild -project TakeRest.xcodeproj -target TakeRest -configuration Release \
	SYMROOT="$PWD/build" -quiet

APP="$PWD/build/Release/TakeRest.app"
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f "$APP"
echo "Built $APP"
