import sys
import typing
import hashlib

f = open("./iprfp3G.dnld", "rb")


def read_section() -> str:
    s = b""
    while True:
        b = f.read(1)
        if not b:
            break
        s += b
        if s.endswith(b"\n\n"):
            break
        if s.endswith(b"\x0A\x0C\x00\xFF\xFF"):
            s = s[:-5]
            break

    return s.decode("ascii")


def header_parts_to_dict(parts: str) -> typing.Dict[str, str]:
    parts = parts.strip().split("\n")
    out = {}
    for p in parts:
        k, v = p.split(" = ", 1)
        out[k] = v

    return out


ft = read_section()
if ft.strip() != "IP-RFP Firmware Image":
    print("Not a MITEL firmware file")
    sys.exit(1)

hh = header_parts_to_dict(read_section())

if hh.get("header version") != "1":
    print("Not a version 1 header")
    sys.exit(1)

header_len = hh.get("header length", "")
if not header_len.endswith(" bytes"):
    print("Invalid header length")
    sys.exit(1)
header_len = int(header_len[:-6])

info = header_parts_to_dict(read_section())

print("--- Firmware info ---")
for k, v in info.items():
    print(f"{k}: {v}")

lens = header_parts_to_dict(read_section())

image_length = int(lens.get("image length", "0 bytes")[:-6])
addon_length = int(lens.get("addon length", "0 bytes")[:-6])

sums = header_parts_to_dict(read_section())

header_md5 = bytes.fromhex(sums["header md5"])
image_md5 = bytes.fromhex(sums["image md5"])
addon_md5 = bytes.fromhex(sums["addon md5"])

f.seek(header_len)
image_data = f.read(image_length)
if image_md5 != hashlib.md5(image_data).digest():
    print("Image data MD5 mismatch")
    sys.exit(1)

addon_data = f.read(addon_length)
if addon_md5 != hashlib.md5(addon_data).digest():
    print("Addon data MD5 mismatch")
    sys.exit(1)

with open("./image", "wb") as i:
    i.write(image_data)

with open("./addon", "wb") as i:
    i.write(addon_data)
