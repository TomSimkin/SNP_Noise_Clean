# SNP_Noise_Clean

A hardware-based image processing system that removes 5% salt-and-pepper noise using a median filter, written entirely in VHDL. Designed for and synthesized on the Altera DE2-115 FPGA development board using Quartus Prime.

## 🧠 Project Overview

This project implements a real-time noise cleaning pipeline using a 3x3 median filter on grayscale images. The architecture uses ROM for image input and RAM for processed image output. The noise cleaning is demonstrated using the standard LENA image with artificially added salt-and-pepper noise.

## 🛠️ Key Features

- ⚙️ Fully implemented in VHDL
- 🖼️ 6-bit grayscale image support
- 🧼 Removes 5% salt-and-pepper noise
- 💾 ROM-based input, RAM-based output
- 🧮 3x3 median filter implementation
- 🧪 Verified in ModelSim using testbench with LENA image
- 🎛️ Target platform: Altera DE2-115 (Cyclone IV)

## 🧩 System Architecture

The system processes grayscale images using a hardware pipeline consisting of the following components:

ROM: Stores the original (noisy) image. Initialized using a .mif file generated from a grayscale image.

3-Row Buffer: Temporarily holds three consecutive image rows to feed the median filter in a sliding window fashion.

Median Filter: Applies a 3x3 median operation to reduce salt-and-pepper noise at each pixel location.

RAM: Stores the cleaned image after processing.

FSM (Finite State Machine): Coordinates read/write operations and controls data flow between ROM, buffer, filter, and RAM.

![image](https://github.com/user-attachments/assets/de88cafc-06a6-4b18-a2f1-5c2594fc7d99)

💡 Each color layer (Red/Green/Blue) is processed separately using this pipeline to support full-color images.

## 🧰 Tools Used

- **VHDL** – for RTL design
- **ModelSim** – for simulation
- **Quartus Prime 20.1** – for synthesis
- **RAW2MIF** – converts image to memory initialization format
- **MIF2RAW** – converts processed output back to viewable image

## 🖼️ Demonstration

From left to right:
1. Original clean image
2. Noisy image (5% noise)
3. Result from Python median filter (reference)
4. Result from VHDL simulation

![image](https://github.com/user-attachments/assets/8f165343-d2fe-4d54-b3f4-efbb32cbafd7)

## 📁 Folder Structure
├── src/ # VHDL source files

├── sim/ # ModelSim simulation files and testbenches

├── images/ # Original, noisy, and output images

├── tools/ # RAW2MIF and MIF2RAW converters

├── docs/ # System architecture diagrams and explanations

└── README.md

## ✅ How to Run

1. Load your image using the provided `RAW2MIF` converter.
2. Simulate the design in ModelSim (`testbench.vhd`).
3. Synthesize the design in Quartus Prime targeting DE2-115.
4. Use `MIF2RAW` to convert the RAM output to an image file.
