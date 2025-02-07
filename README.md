# SNP_Noise
Hardware-based image processing system that cleans 5% "salt and pepper" noise.
Written entirely in VHDL and synthesized using Quartus Prime on Altera DE2-115 Development and Education Board.

The project involves designing a hardware-based image processing system that applies a median of medians filter to an image. 
The system operates using ROM and RAM memory blocks, where the original image is stored in ROM, and the processed image is stored in RAM.

Memory Setup:

The input image is stored in ROM.
The processed image is stored in RAM.
Memory blocks are configured using MEGA WIZARD and the In System Memory Content Editor.

Image Data Handling:

A RAW2MIF tool converts the original image into a format that can be loaded into ROM.
The image data is stored as a 6-bit grayscale representation.

Simulation and Verification:

The processing is tested in ModelSim, with verification using known image test cases (e.g., LENA image with 5% salt-and-pepper noise).
The system reads the processed image from RAM and exports it using MIF2RAW, converting it back to an image format.

System Architecture:

![image](https://github.com/user-attachments/assets/de88cafc-06a6-4b18-a2f1-5c2594fc7d99)

The project is demonstrated in the image below, comparing Lena (https://en.wikipedia.org/wiki/Lenna#:~:text=Lenna%20(or%20Lena)%20is%20a,1972%20issue%20of%20Playboy%20magazine.):

![image](https://github.com/user-attachments/assets/8f165343-d2fe-4d54-b3f4-efbb32cbafd7)
