# extract_image.py
import sys

with open(sys.argv[1], 'rb') as f:
    data = f.read()

# Parse BMP header
pixel_offset = int.from_bytes(data[10:14], 'little')
width = int.from_bytes(data[18:22], 'little')
height = int.from_bytes(data[22:26], 'little')

# Validate format
assert width == 320 and height == 200, f"Expected 320x200, got {width}x{height}"
assert int.from_bytes(data[28:30], 'little') == 8, "Not an 8-bit BMP"
assert int.from_bytes(data[30:34], 'little') == 0, "BMP is compressed"

# Extract palette (BGR0 ? RGB, scaled to 0-63)
palette = bytearray()
for i in range(54, 54 + 256*4, 4):
    b = (data[i]   * 63) // 255  # Better scaling (0-255 ? 0-63)
    g = (data[i+1] * 63) // 255
    r = (data[i+2] * 63) // 255
    palette += bytes([r, g, b])

# Extract pixels (bottom-to-top)
pixels = bytearray()
bytes_per_row = 320
for row in reversed(range(height)):
    start = pixel_offset + row * bytes_per_row
    end = start + bytes_per_row
    pixels += data[start:end]

# Verify sizes
assert len(palette) == 768, f"Palette size: {len(palette)}"
assert len(pixels) == 64000, f"Pixel size: {len(pixels)}"

# Write output
with open(sys.argv[2], 'wb') as f:
    f.write(palette)
    f.write(pixels)