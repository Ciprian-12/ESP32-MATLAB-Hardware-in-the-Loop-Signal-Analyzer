# ESP32-MATLAB-Hardware-in-the-Loop-Signal-Analyzer


## 📖 Project Description 
## This project implements a Hardware-in-the-Loop (HIL) testing architecture, combining the versatility of an ESP32 microcontroller with the computational power (DSP) of MATLAB. The system operates simultaneously as a digital function generator, a mechanical actuator controller, and a real-time spectral analyzer.

## Unlike a standard passive measurement instrument, this system mathematically generates complex waveforms (sine, square, triangle), translates them instantly into physical motion via a servomotor, and transmits the raw data to the PC. MATLAB captures this continuous data stream to render a dynamic graphical interface and decompose the signals in the frequency domain using the Fast Fourier Transform (FFT).


## 🚀 Key Features
## Direct Digital Synthesis (DDS): Precise waveform generation using the processor's internal clock and the ESP32's 12-bit resolution, translated into a safe operational range of 0.16V – 3.06V to protect the mechanical actuator.

## Advanced Spectral Analysis: Raw data processing in MATLAB (using a 1000-point buffer) to isolate the fundamental frequency and odd harmonics, practically demonstrating Fourier's Theorem.

## Mechanical Synchronization (PWM): Mathematical mapping of the waveform into a physical angle (0° - 180°) and driving an MG90S servomotor via the GPIO 18 pin with minimal latency.

## Bidirectional Serial Communication: A stable distributed architecture running at 115200 baud, where the microcontroller strictly handles physical timing (microsecond level), while# the PC manages heavy mathematical calculations and dynamic UI rendering.


## 🛠️ Technologies Used
## Hardware: ESP32 DevKit V1, Servomotor (MG90S/SG90), Breadboard (Point-to-Point routing)

## Software: C++ (Arduino IDE) for control logic, MATLAB for signal processing and GUI

## Concepts: HIL, DSP, FFT, PWM, Nyquist-Shannon Sampling Theorem
