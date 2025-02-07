import cv2
import numpy as np

def memfile_to_array(filename, pixel_depth=8, width=256, height=16):
    rows = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            # Skip lines that do not contain the expected format
            if ':' not in line:
                continue
            try:
                # Extract the bitstring part after ":"
                bits_str = line.split(":", 1)[1].strip().replace(";", "")
                row_bytes = []
                # Process the line in chunks of `pixel_depth` bits
                for i in range(0, len(bits_str), pixel_depth):
                    chunk = bits_str[i : i + pixel_depth]
                    # Pad if pixel_depth < 8
                    chunk = chunk.ljust(8, '0')
                    row_bytes.append(int(chunk, 2))
                rows.append(row_bytes)
            except (ValueError, IndexError):
                # Skip lines that fail to process
                continue

    # Ensure the resulting array matches the desired dimensions
    rows = rows[:height]  # Limit to `height`
    for row in rows:
        row.extend([0] * (width - len(row)))  # Pad rows to `width`
    return np.array(rows, dtype=np.uint8)

def median_of_medians_3x3_rgb(img):
    """Row-based median of medians filter (3×3) for an RGB image."""
    if len(img.shape) != 3 or img.shape[2] != 3:
        raise ValueError("Input must have shape (H, W, 3).")

    h, w, _ = img.shape
    out = np.zeros_like(img)

    for c in range(3):
        # Pad single channel for 3x3 neighborhoods
        padded = cv2.copyMakeBorder(img[..., c], 1, 1, 1, 1, cv2.BORDER_REFLECT)
        for y in range(h):
            for x in range(w):
                # Extract 3x3 patch
                patch_3x3 = padded[y : y+3, x : x+3]
                # For each of the 3 rows, find the row's median -> collect them
                row_medians = [np.sort(patch_3x3[r, :])[1] for r in range(3)]
                # The final pixel is the median of the 3 row-medians
                out[y, x, c] = np.sort(row_medians)[1]

    return out

def load_raw_rgb(filename, width, height):
    """
    Loads a 3-channel RGB raw image (8 bits/channel) from filename.
    Returns a NumPy array of shape (height, width, 3).
    """
    data = np.fromfile(filename, dtype=np.uint8)
    expected_size = width * height * 3
    if data.size != expected_size:
        raise ValueError("Size mismatch. Check raw dimensions.")
    # Reshape as (height, width, 3)
    img_rgb = data.reshape((height, width, 3))
    return img_rgb

# Convert each mem file into a 2D array
r_data = memfile_to_array('r.mif', pixel_depth=8,  width=256, height=256)
g_data = memfile_to_array('g.mif', pixel_depth=8,  width=256, height=256)
b_data = memfile_to_array('b.mif', pixel_depth=8, width=256, height=256)

# Stack along the third axis to get an RGB array: shape (256, 256, 3)
rgb_array = np.dstack([r_data, g_data, b_data])  # RGB format

# OpenCV uses BGR by default, so we should convert RGB -> BGR
bgr_array = cv2.cvtColor(rgb_array, cv2.COLOR_RGB2BGR)

# Load raw RGB images for comparison
original = load_raw_rgb("lena.raw", 256, 256)
original = cv2.cvtColor(original, cv2.COLOR_RGB2BGR)

original_noise = load_raw_rgb("lena_noise.raw", 256, 256)
original_noise = cv2.cvtColor(original_noise, cv2.COLOR_RGB2BGR)

# Apply the median of medians filter
filtered_image = median_of_medians_3x3_rgb(original_noise)

# Display the images
cv2.imshow("Result_simulation", bgr_array)
cv2.imshow("Original", original)
cv2.imshow("Original with Noise", original_noise)
cv2.imshow("Filtered Image", filtered_image)

# Save the output
cv2.imwrite("out_simulation.png", bgr_array)
cv2.imwrite("filtered_image.png", filtered_image)

cv2.waitKey(0)
cv2.destroyAllWindows()
