# Genetic-Cutting-Stock
An evolutionary algorithm for solving the two dimensional cutting stock problem.
**WARNING**: The current version only supports **HUNGARIAN** language.

## Purpose of writing this algorithm
This program was written for the "Projektmunka 1" course at Széchenyi István University, Győr, Hungary.

## How to use it?
The current version is `0.1` alpha. **I don't recommend using the algorithm for any essential work yet.**
If you want to check out the current version, I recommend you following these steps:
- Download the **GUI folder** of this repository.
- Start the `Project1.exe` file.
- Use the `Hozzáadás` button to add new planks to the list of items in stock (*Készlet*) or to the list of items to be cut (*Kivágandó*). 
- Use the `Töröl` button to delete items from these lists.
- Use the `Megoldás keresése` button to find a solution for the given problem. 
- As the ProgressBar at the bottom of the window progresses, so does the algorithm get closer and closer to finding a solution. 
- After the ProgressBar is full, a window pops up telling you if the cuts could be done or not.
- If the cuts could be done on the items in stock, the result will be shown as SVG images.
