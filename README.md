What the script should do (when calling o):

Store content in data memory:
- Circle(, , )
- Line(, , )

Calling a method will:
1. store the arguments in a0-a2
2. run the equivalent method asm script
    - results will be stored in the memory array (as described in the spec)

- there will be a variable that keeps track of the index of next place to store
- array ends at zero
