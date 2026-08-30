#!/usr/bin/env python3

import os
import struct
import sys

SECTOR_SIZE = 512
FILE_SIZE = 3 * SECTOR_SIZE
DATA_SIZE = 2 * SECTOR_SIZE
DEFAULT_LOAD = 0x5000
FILE_COUNT = 32


def make_sfs(directory, output, load=DEFAULT_LOAD):
    files = [
        name for name in os.listdir(directory)
        if os.path.isfile(os.path.join(directory, name))
    ]

    if len(files) > FILE_COUNT:
        raise ValueError("Too many files")

    image = bytearray(SECTOR_SIZE)

    image[0:3] = b"SFS"
    struct.pack_into("<H", image, 3, FILE_COUNT)

    for file_id, name in enumerate(files, 1):
        path = os.path.join(directory, name)

        filename = name.encode("ascii")

        if len(filename) > 31:
            raise ValueError(f"Filename too long: {name}")

        with open(path, "rb") as f:
            data = f.read()

        if len(data) > DATA_SIZE:
            raise ValueError(
                f"{name} is too large ({len(data)} bytes, max {DATA_SIZE})"
            )

        file_image = bytearray(FILE_SIZE)

        file_image[0:len(filename)] = filename
        struct.pack_into("<H", file_image, 32, load)

        file_image[SECTOR_SIZE:SECTOR_SIZE + len(data)] = data

        image += file_image

    null_file = bytearray(FILE_SIZE)
    struct.pack_into("<H", null_file, 32, load)
    null_file[SECTOR_SIZE:SECTOR_SIZE + 2] = b"\xCD\x21"

    for _ in range(FILE_COUNT - len(files)):
        image += null_file

    with open(output, "wb") as f:
        f.write(image)


if __name__ == "__main__":
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print(f"usage: {sys.argv[0]} <directory> <output> [default load segment]")
        sys.exit(1)

    directory = sys.argv[1]
    output = sys.argv[2]

    load = DEFAULT_LOAD

    if len(sys.argv) == 4:
        load = int(sys.argv[3], 0)

    make_sfs(directory, output, load)
