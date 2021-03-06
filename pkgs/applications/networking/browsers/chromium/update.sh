#!/bin/sh

channels_url="http://omahaproxy.appspot.com/all?csv=1";
bucket_url="http://commondatastorage.googleapis.com/chromium-browser-official/";
output_file="$(cd "$(dirname "$0")" && pwd)/sources.nix";

nix_getattr()
{
    input_file="$1";
    attr="$2";

    var="$(nix-instantiate --eval-only -A "$attr" "$output_file")";
    echo "$var" | tr -d '\\"';
}

### poor mans key/value-store :-) ###

ver_sha_table=""; # list of version:sha256

sha_lookup()
{
    version="$1";

    for ver_sha in $ver_sha_table;
    do
        if [ "x${ver_sha%:*}" = "x$version" ];
        then
            echo "${ver_sha##*:}";
            return 0;
        fi;
    done;

    return 1;
}

sha_insert()
{
    version="$1";
    sha256="$2";

    ver_sha_table="$ver_sha_table $version:$sha256";
}

if [ -e "$output_file" ];
then
    get_sha256()
    {
        channel="$1";
        version="$2";
        url="$3";

        oldver="$(nix_getattr "$output_file" "$channel.version")";

        echo -n "Checking if $oldver ($channel) is up to date..." >&2;

        if [ "x$version" != "x$oldver" ];
        then
            echo " no, getting sha256 for new version $version:" >&2;
            sha256="$(nix-prefetch-url "$url")";
        else
            echo " yes, keeping old sha256." >&2;
            sha256="$(nix_getattr "$output_file" "$channel.sha256")";
        fi;

        sha_insert "$version" "$sha256";
        echo "$sha256";
    }
else
    get_sha256()
    {
        nix-prefetch-url "$url";
    }
fi;

get_channel_exprs()
{
    for chline in $(echo "$1" | cut -d, -f-2);
    do
        channel="${chline%%,*}";
        version="${chline##*,}";

        # XXX: Remove case after version 26 is stable:
        if [ "${version%%.*}" -ge 26 ]; then
            url="${bucket_url%/}/chromium-$version.tar.xz";
        else
            url="${bucket_url%/}/chromium-$version.tar.bz2";
        fi;

        echo -n "Checking if sha256 of version $version is cached..." >&2;
        if sha256="$(sha_lookup "$version")";
        then
            echo " yes: $sha256" >&2;
        else
            echo " no." >&2;
            sha256="$(get_sha256 "$channel" "$version" "$url")";
        fi;

        sha_insert "$version" "$sha256";

        echo "  $channel = {";
        echo "    version = \"$version\";";
        echo "    url = \"$url\";";
        echo "    sha256 = \"$sha256\";";
        echo "  };";
    done;
}

cd "$(dirname "$0")";

omaha="$(curl -s "$channels_url")";
versions="$(echo "$omaha" | sed -n -e 's/^linux,\(\([^,]\+,\)\{2\}\).*$/\1/p')";
channel_exprs="$(get_channel_exprs "$versions")";

cat > "$output_file" <<-EOF
# This file is autogenerated from update.sh in the same directory.
{
$channel_exprs
}
EOF
