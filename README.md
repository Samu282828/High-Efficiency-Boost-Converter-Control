
Design and simulation of a high-efficiency (97.2%+) DC-DC Boost Converter (10V to 20V). Includes feedback controller design and verification using LTSpice and Matlab/Scilab.
# High-Efficiency DC-DC Boost Converter with Feedback Control

## Project Overview
This project focuses on the design, modeling, and simulation of a **Step-Up (Boost) Converter**. The goal was to achieve high energy efficiency and stable output voltage regulation under variable load conditions.

## Technical Specifications
* **Input Voltage ($V_{in}$):** 10 V
* **Output Voltage ($V_{out}$):** 20 V
* **Efficiency:** > 97.2% across a wide range of loads.
* **Controller:** Closed-loop feedback control implemented to ensure regulation and stability.

## Tools & Methodology
* **Matlab / Scilab:** Used for the mathematical modeling of the converter (Small Signal Analysis) and for calculating the compensator parameters (PID/Type II-III) to meet phase margin and bandwidth requirements.
* **LTSpice:** Used for circuit-level validation, including realistic component models (ESR of capacitors, RDC of inductors) to verify efficiency and ripple specifications.

## Key Features
* **Efficiency Optimization:** Careful selection of switching frequency and power components to minimize conduction and switching losses.
* **Feedback Control:** Design of a robust control loop to maintain a steady 20V output despite input voltage fluctuations or load changes.
* **Stability Analysis:** Bode plots and transient response verification.

## Repository Content
* `Simulation/`: LTSpice schematic files (.asc).
* `Analysis/`: Matlab/Scilab scripts for transfer function calculation and control tuning.
* `Docs/`: Technical report or summary of results.

## Author
**Samuele De Carlo** - MSc Student in Electronic Engineering | University of Pisa
