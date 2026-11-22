"""Install just the single-threaded Web templates from Godot's official TPZ."""

import io
import re
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path


class RemoteZip(io.RawIOBase):
    def __init__(self, url):
        self.url = url
        self.offset = 0
        with self.request("0-0") as response:
            content_range = response.headers.get("Content-Range", "")
            match = re.fullmatch(r"bytes 0-0/([0-9]+)", content_range)
            if response.status != 206 or match is None:
                raise OSError("Godot's template mirror does not support partial downloads")
            self.length = int(match.group(1))
            self.url = response.geturl()

    def request(self, span):
        request = urllib.request.Request(self.url, headers={
            "User-Agent": "EdoGardenDefense-WebBuild/1.0",
            "Range": f"bytes={span}",
        })
        return urllib.request.urlopen(request, timeout=90)

    def readable(self):
        return True

    def seekable(self):
        return True

    def tell(self):
        return self.offset

    def seek(self, offset, whence=io.SEEK_SET):
        base = {io.SEEK_SET: 0, io.SEEK_CUR: self.offset, io.SEEK_END: self.length}
        position = base[whence] + offset
        if position < 0:
            raise OSError("Cannot seek before the archive")
        self.offset = position
        return position

    def read(self, size=-1):
        available = max(0, self.length - self.offset)
        size = available if size < 0 else min(available, size)
        if not size:
            return b""
        end = self.offset + size - 1
        span = f"{self.offset}-{end}"
        with self.request(span) as response:
            if response.status != 206 or response.headers.get("Content-Range") != f"bytes {span}/{self.length}":
                raise OSError(f"Godot's template download did not honor byte range {span}")
            data = response.read(size)
        if len(data) != size:
            raise OSError(f"Incomplete Godot template download for byte range {span}")
        self.offset += size
        return data


def install(version, directory):
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version):
        raise ValueError("Expected a stable Godot version such as 4.7.2")
    names = ["web_nothreads_release.zip", "web_nothreads_debug.zip"]
    missing = [name for name in names if not zipfile.is_zipfile(directory / name)]
    if not missing:
        return
    release = f"{version}-stable"
    url = f"https://github.com/godotengine/godot-builds/releases/download/{release}/Godot_v{release}_export_templates.tpz"
    directory.mkdir(parents=True, exist_ok=True)
    # ZipFile seeks to the directory and reads only the requested members.
    with RemoteZip(url) as remote, zipfile.ZipFile(remote) as archive:
        with tempfile.TemporaryDirectory(dir=directory) as staging:
            for name in missing:
                print(f"Downloading Godot {version} {name}", flush=True)
                temporary = Path(staging) / name
                temporary.write_bytes(archive.read(f"templates/{name}"))
                temporary.replace(directory / name)


if __name__ == "__main__":
    install(sys.argv[1], Path(sys.argv[2]))
