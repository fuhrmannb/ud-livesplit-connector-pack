#!/usr/bin/env python3

import argparse
import io

from urllib.request import urlopen
from typing import TextIO
from zipfile import ZipFile

LIVESPLIT_CONNECT_VERSION = "0.1.0"
GRPC_MULTIPLEXER_VERSION = "0.1.0"

LIVESPLIT_CONNECT_DOWNLOAD_URL = f"https://github.com/fuhrmannb/LiveSplit.Connect/releases/download/v{LIVESPLIT_CONNECT_VERSION}/LiveSplit.Connect_{LIVESPLIT_CONNECT_VERSION}_Windows_x86_64.zip"
GRPC_MULTIPLEXER_DOWNLOAD_URL = f"https://github.com/fuhrmannb/grpc-multiplexer/releases/download/v{GRPC_MULTIPLEXER_VERSION}/grpc-multiplexer_{GRPC_MULTIPLEXER_VERSION}_Windows_x86_64.zip"

LIVESPLIT_CONNECT_ZIP_DEST_FOLDER = "LiveSplit.Connect"
GRPC_MULTIPLEXER_ZIP_DEST_FOLDER = "multiplexer-client"

GRPC_MULTIPLEXER_ZIP_SRC_CLIENT = "grpc-multiplexer-client.exe"
GRPC_MULTIPLEXER_SCRIPTS = [
    "ud_multiplexer_client_wrapper.ps1",
    "ud-multiplexer-client.bat",
]

README_FILES = ["README.md", "README.en.md"]


def main(output: str):
    # Create zip archive
    with ZipFile(output, "w") as output_zip:

        # Download LiveSplit.Connect and copy whole content
        with urlopen(LIVESPLIT_CONNECT_DOWNLOAD_URL) as livesplit_dl:
            with io.BytesIO(livesplit_dl.read()) as b, ZipFile(b, "r") as livesplit_zip:
                for livesplit_zip_file in livesplit_zip.namelist():
                    with livesplit_zip.open(livesplit_zip_file) as in_file:
                        output_zip.writestr(
                            f"{LIVESPLIT_CONNECT_ZIP_DEST_FOLDER}/{livesplit_zip_file}",
                            in_file.read(),
                        )

        # Download GRPC Multiplexer and copy client
        with urlopen(GRPC_MULTIPLEXER_DOWNLOAD_URL) as multiplexer_dl:
            with io.BytesIO(multiplexer_dl.read()) as b, ZipFile(
                b, "r"
            ) as multiplexer_zip:
                with multiplexer_zip.open(GRPC_MULTIPLEXER_ZIP_SRC_CLIENT) as in_file:
                    output_zip.writestr(
                        f"{GRPC_MULTIPLEXER_ZIP_DEST_FOLDER}/{GRPC_MULTIPLEXER_ZIP_SRC_CLIENT}",
                        in_file.read(),
                    )

        # Copy script for multiplexer-client
        for script in GRPC_MULTIPLEXER_SCRIPTS:
            output_zip.write(script, f"{GRPC_MULTIPLEXER_ZIP_DEST_FOLDER}/{script}")

        # Copy READMEs
        for readme in README_FILES:
            output_zip.write(readme)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="UD multpliexer client archive builder"
    )
    parser.add_argument("output", type=str, help="name of the output archive")
    args = parser.parse_args()
    main(args.output)
