#!/usr/bin/env pwsh

###############
# Install k9s #
###############

# Every package should define these variables
$pkg_cmd_name = "k9s"

$pkg_dst_cmd = "$Env:USERPROFILE\.local\bin\k9s.exe"
$pkg_dst = "$pkg_dst_cmd"

$pkg_src_cmd = "$Env:USERPROFILE\.local\opt\k9s-v$Env:WEBI_VERSION\bin\k9s.exe"
$pkg_src_bin = "$Env:USERPROFILE\.local\opt\k9s-v$Env:WEBI_VERSION\bin"
$pkg_src_dir = "$Env:USERPROFILE\.local\opt\k9s-v$Env:WEBI_VERSION"
$pkg_src = "$pkg_src_cmd"

$pkg_download = "$Env:USERPROFILE\Downloads\$Env:WEBI_PKG_FILE"

# Fetch archive
IF (!(Test-Path -Path "$Env:USERPROFILE\Downloads\$Env:WEBI_PKG_FILE"))
{
    # TODO: arch detection
    echo "Downloading k9s from $Env:WEBI_PKG_URL to $pkg_download"
    & curl.exe -A -L "$Env:WEBI_UA" -fsSL "$Env:WEBI_PKG_URL" -o "$pkg_download.part"
    & move "$pkg_download.part" "$pkg_download"
}

IF (!(Test-Path -Path "$pkg_src_cmd"))
{
    echo "Installing k9s"

    # TODO: create package-specific temp directory
    # Enter tmp
    pushd .local\tmp

        # Remove any leftover tmp cruft
        Remove-Item -Path ".\k9s-v*" -Recurse -ErrorAction Ignore
        Remove-Item -Path ".\k9s.exe" -Recurse -ErrorAction Ignore

        # Unpack archive file into this temporary directory
        # Windows BSD-tar handles zip. Imagine that.
        echo "Unpacking $pkg_download"
        & tar xf "$pkg_download"

        # Settle unpacked archive into place
        echo "Install Location: $pkg_src_cmd"
        New-Item "$pkg_src_bin" -ItemType Directory -Force        
        Move-Item -Path "k9s.exe" -Destination "$pkg_src_bin"

    # Exit tmp
    popd
}

echo "Copying into '$pkg_dst_cmd' from '$pkg_src_cmd'"
Remove-Item -Path "$pkg_dst_cmd" -Recurse -ErrorAction Ignore
Copy-Item -Path "$pkg_src" -Destination "$pkg_dst" -Recurse
Remove-Item -Path "$pkg_src" -Recurse -ErrorAction Ignore
