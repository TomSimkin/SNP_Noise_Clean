import numpy as np


def raw_to_mif(input_file, width, height):
    # Read raw file
    with open(input_file, 'rb') as f:
        raw_data = np.frombuffer(f.read(), dtype=np.uint8)

    # Check if the data matches the expected size
    expected_size = width * height * 3  # RGB format
    if len(raw_data) != expected_size:
        raise ValueError(f"Invalid raw file size. Expected {expected_size} bytes, got {len(raw_data)} bytes.")

    # Reshape into (height, width, 3) array
    image = raw_data.reshape((height, width, 3))

    # Extract channels and mask to 6 bits
    r, g, b = (image[:, :, 0] & 0x3F), (image[:, :, 1] & 0x3F), (image[:, :, 2] & 0x3F)

    # Function to write MIF file in binary format
    def write_mif(filename, data):
        depth = 256
        width = 1536
        with open(filename, 'w') as f:
            f.write(f"DEPTH = {depth};\nWIDTH = {width};\nADDRESS_RADIX = BIN;\nDATA_RADIX = BIN;\nCONTENT BEGIN\n")
            for i, row in enumerate(data):
                binary_values = ''.join(f"{value:06b}" for value in row)
                f.write(f"{i:08b} : {binary_values};\n")  # Binary format
            f.write("END;")

    # Write each channel to separate MIF files
    write_mif('r.mif', r)
    write_mif('g.mif', g)
    write_mif('b.mif', b)

    print("MIF files generated: r.mif, g.mif, b.mif")


# Example usage (adjust width and height accordingly)
raw_to_mif('lena.raw', width=256, height=256)