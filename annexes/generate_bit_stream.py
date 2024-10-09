#!/usr/bin/python3
import sys
from struct import pack, unpack

FLOAT_SIZE = 32

def float_2_raw(f: float):
    return unpack('<I', pack('<f', f))[0]

def c_lead_zero_count(v: str):
    return len(v.split("1")[0])

def significant_bits_size(v: str):
    return len(v.strip("0"))

previous = None
c_bit_start = 0
c_windows_size = 0

raw_bit_flow = "0b"
compressed_bit_flow = "0b"

for line in sys.stdin:
  i = float(line.strip())
  raw_i = float_2_raw(i)
  raw_bit_flow += f" {raw_i:032b}"
  new_window = False
  # First iteration
  if previous is None:
    print(f"{raw_i:032b}({i:2.0f}) - init\n")
    compressed_bit_flow += f" {raw_i:032b}"
    previous = i
    continue

  xor = (float_2_raw(previous) ^ raw_i)
  # No change
  if xor == 0:
    print(f"{xor:032b}({i:2.0f}): zero  - 0")
    compressed_bit_flow += " 0"
    previous = i
    continue

  bin_str = f"{xor:032b}"
  bit_start = c_lead_zero_count(bin_str)

  windows_size = significant_bits_size(bin_str)
  if c_bit_start != bit_start or c_windows_size != windows_size:
    if c_windows_size < windows_size or c_bit_start > bit_start:
        (c_bit_start, c_windows_size) = (bit_start, windows_size)
        new_window = True
    if bit_start >= c_bit_start + c_windows_size:
        (c_bit_start, c_windows_size) = (bit_start, windows_size)
        new_window = True

  bits_to_send = bin_str[c_bit_start:c_bit_start+c_windows_size]
  msg = "reuse"
  header = 10
  _bit_flow = f"{header} {bits_to_send}"
  if new_window:
      msg = "new window"
      _bit_flow = f"11 {bit_start:05b} {windows_size:06b}"
      header = f"(start={c_bit_start} size={c_windows_size}) {_bit_flow}"
  print(f"{xor:032b}({i:2.0f}): {msg:5} - {header} {bits_to_send}")
  compressed_bit_flow += f" {_bit_flow}"

  previous = i

print(f"\nRaw bit flow        = {raw_bit_flow}")
print(f"\nCompressed bit flow = {compressed_bit_flow}")
