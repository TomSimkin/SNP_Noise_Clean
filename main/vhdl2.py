import cv2
import numpy as np

def memfile_to_array(filename, bit_depth=6):
    """
    Reads a mem file and converts it into a 2D NumPy array.
    Pads each pixel value to 8 bits by appending zeros.
    """
    rows = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue  # Skip empty lines
            address_part, bits_str = line.split(':', 1)
            bits_str = bits_str.strip()

            # Convert bit_depth chunks to integers and pad each value to 8 bits
            row_bytes = [
                int(bits_str[i : i + bit_depth].ljust(8, '0'), 2)
                for i in range(0, len(bits_str), bit_depth)
            ]
            rows.append(row_bytes)

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
                patch_3x3 = padded[y : y + 3, x : x + 3]
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

if __name__ == "__main__":
    # Convert each mem file into a 2D array (6-bit per pixel)
    r_data = memfile_to_array('r.mem', bit_depth=6)  # shape: (256, 256)
    g_data = memfile_to_array('g.mem', bit_depth=6)  # shape: (256, 256)
    b_data = memfile_to_array('b.mem', bit_depth=6)  # shape: (256, 256)

    # Stack along the third axis to get an RGB array: shape (256, 256, 3)
    rgb_array = np.dstack([r_data, g_data, b_data])  # RGB format

    # OpenCV uses BGR by default, so we should convert RGB -> BGR
    bgr_array = cv2.cvtColor(rgb_array, cv2.COLOR_RGB2BGR)

    # Load original and noisy raw images
    original = load_raw_rgb("lena.raw", 256, 256)
    original = cv2.cvtColor(original, cv2.COLOR_RGB2BGR)
    print(f"Image shape: {original.shape}")

    original_noise = load_raw_rgb("lena_noise.raw", 256, 256)
    original_noise = cv2.cvtColor(original_noise, cv2.COLOR_RGB2BGR)

    # Apply the median of medians filter
    ans = median_of_medians_3x3_rgb(original_noise)

    # Display the images
    cv2.imshow("Result_simulation", bgr_array)
    cv2.imshow("original", original)
    cv2.imshow("original_noise", original_noise)
    cv2.imshow("result_python_function", ans)
    cv2.imwrite("out.png", ans)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
