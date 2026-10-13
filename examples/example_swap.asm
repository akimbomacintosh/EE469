SWAP:
    LSL X2, X1, #3 //X2 = 8*k
    ADD X2, X0, X2 //address of v[k]
    LDUR X3, [X2, #0] //X3 = v[k]
    LDUR X4, [X2, #8] //X4 = v[k+1]
    STUR X4, [X2, #0] //v[k] = v[k+1]
    STUR X3, [X2, #8] //v[k+1] = v[k]
