#!/usr/bin/python3

from struct import pack, unpack
FLOAT_SIZE = 32

def float_2_raw(f: float):
    return unpack('<I', pack('<f', f))[0]


def c_lead_zero_count(v: str):
    return len(v.split("1")[0])

def significative_bits_size(v: str):
    return len(v.strip("0"))

previous = None
c_bit_start = 0
c_windows_size = 0

for i in [10, 11, 12, 13, 14, 16, 17, 18, 19, 20]:
  # [1, 2, 3, 3, 4, 5, 6, 9, 10, 11, 11, 12, 14, 15, 16, 17, 17, 18, 19, 20]:
  i = float(i)
  new_window = False
  # First iteration
  if previous is None:
    xor = float_2_raw(i)
    print(f"{xor:032b} - init\n") 
    previous = i
    continue

  xor = (float_2_raw(previous) ^ float_2_raw(i))
  # No change
  if xor == 0:
    print(f"{xor:032b}({i:2.0f}): zero  - 0")
    previous = i
    continue

  bin_str = f"{xor:032b}"
  bit_start = c_lead_zero_count(bin_str)

  windows_size = significative_bits_size(bin_str)
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
  if new_window:
      msg = "new w"
      header = f"(start={c_bit_start} size={c_windows_size}) 11 {bit_start:05b} {windows_size:06b}"
  print(f"{xor:032b}({i:2.0f}): {msg:5} - {header} {bits_to_send}")

  previous = i
