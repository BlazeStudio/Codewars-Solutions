# Build Tower
# https://www.codewars.com/kata/576757b1df89ecf5bd00073b
#Build Tower
# Build a pyramid-shaped tower, as an array/list of strings, given a positive integer number of floors. A tower block is represented with "*" character.
#
# For example, a tower with 3 floors looks like this:

def tower_builder(n_floors):
    floors = []
    stars = 1;
    empties = n_floors * 2 - 2;
    for i in range(n_floors):
        floors.append(' ' * (empties//2) + ('*')*stars + ' ' * (empties // 2)); stars += 2; empties -= 2;
    return floors