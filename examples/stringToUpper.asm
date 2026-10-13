// if (*index >= 'a' && *index <= 'z') 
    // *index = *index +('A' - 'a') // convert to uppercase


LDUR X0, [X31, #80] // index = string
LOOP:
    LDURB X1, [X0, #0]  // load byte *index
    CBZ X1, END         // exit loop if *index == 0
    CMPI X1, #97        // *index vs 'a'
    B.LT NEXT           // dont change if *index < 'a'
    CMPI X1, #122       // *index vs 'z'
    B.GT NEXT           // dont change if *index > 'z'

    SUBI X1, X1, #32     // X1 = *index + ('A' - 'a')
    STURB X1, [X0, #0]      // store back to *index
NEXT:
    ADDI X0, X0, #1      // index++   if you are doing a register and constant, do add "I"
    B LOOP
END: