if [[ "$*" == *"release"* ]]; then
	PK3_RELEASE=1
fi

. defaults.sh

testCmd() {
	if ! command -v $@ &> /dev/null
	then
	    echo "$@ could not be found, please install the required package."
	    exit
	fi
}

testCmd "zip";
testCmd "ln";

PK3_FLAGS=${PK3_FLAGS:-$PK3_FLAGS_DEF}
PK3_VERSION=${PK3_VERSION:-$PK3_VERSION_DEF}
PK3_NAME=${PK3_NAME:-$PK3_NAME_DEF}
FOLDER_NAME=${FOLDER_NAME:-$FOLDER_NAME_DEF}

PK3_FULLNAME="$PK3_FLAGS"_"$PK3_NAME"-"$PK3_VERSION"

PK3_COMMIT=$(git rev-parse --short HEAD)

if [[ "$*" == *"cleanbuilds"* ]]; then
	shopt -s extglob

	# Clean files that aren't .gitignore that contain +, but don't contain the current commit hash.
	FILES_TO_RM=$(find builds -type f ! -name "*.gitignore*" -name "*+*" ! -name "*$PK3_COMMIT*")

	if [ "$FILES_TO_RM" != "" ]; then
		rm $FILES_TO_RM
	fi

	# Clean files that aren't .gitignore that don't match our current version.
	FILES_TO_RM=$(find builds -type f ! -name "*.gitignore*" ! -name "*$PK3_VERSION*")

	if [ "$FILES_TO_RM" != "" ]; then
		rm $FILES_TO_RM
	fi

	exit # Don't create pk3
fi

if [[ ! $PK3_RELEASE ]]; then
	if [[ "$*" == *"discord"* ]]; then
		PK3_TIME=$(date +"%m.%d.%y-%H.%M.%S")

		PK3_METADATA="$PK3_COMMIT"_"$PK3_TIME"
		PK3_FULLNAME="$PK3_FULLNAME"-discord_"$PK3_METADATA"
	else
		PK3_TIME=$(date +"%m.%d.%y-%H.%M.%S")

		PK3_METADATA="$PK3_COMMIT"_"$PK3_TIME"
		PK3_FULLNAME="$PK3_FULLNAME"+"$PK3_METADATA"
	fi
fi

PK3_FILES=${PK3_FILES:-$(cat <<-END
	init.lua
	README.txt
	Maps/*
	Lua/*
	SOC/*
	Sprites/*
	Audio/*
END
)}

cd $FOLDER_NAME
#rm ../builds/$PK3_FULLNAME.pk3
zip -FSr ../builds/$PK3_FULLNAME.pk3 $(echo $PK3_FILES | tr '\r\n' ' ')

# No syn link for now... A bit redundant
#cd ..
#ln -sf builds/$PK3_FULLNAME.pk3 $PK3_NAME.pk3

echo "Build is located at builds/$PK3_FULLNAME.pk3"
