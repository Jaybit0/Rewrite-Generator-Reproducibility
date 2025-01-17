::RULE
MATRIX:lambda,tmp29242
FLOAT:tmp76886

sum(*(*(lambda,tmp76886),tmp29242))
=>
*(tmp76886,sum(*(lambda,tmp29242)))

::RULE
MATRIX:lambda,tmp29242
FLOAT:tmp76886

sum(*(*(tmp76886,lambda),tmp29242))
=>
*(tmp76886,sum(*(lambda,tmp29242)))

::RULE
MATRIX:A,C,D
FLOAT:b

-(A,/(*(b,C),D))
=>
-*(A,b,/(C,D))

::RULE
MATRIX:A,B

t(%*%(t(B),A))
=>
%*%(t(A),B)

::RULE
MATRIX:B
FLOAT:a
LITERAL_FLOAT:1.0

*(/(1.0,B),a)
=>
/(a,B)

::RULE
MATRIX:A,B
LITERAL_FLOAT:1.0

*(/(1.0,B),A)
=>
/(A,B)

::RULE
MATRIX:A

-(+(A,$1:literal.FLOAT()),$2:literal.FLOAT())
=>
+(A,-($1,$2))

::RULE
FLOAT:tmp42877,tmp10220

-(cast.MATRIX(tmp42877),tmp10220)
=>
cast.MATRIX(-(tmp42877,tmp10220))

::RULE
MATRIX:A
FLOAT:a

t(+(A,a))
=>
+(t(A),a)

::RULE
MATRIX:A,B
LITERAL_FLOAT:0.0

-(0.0, -(A, B))
=>
-(B, A)

::RULE
MATRIX:A,B

t(==(A,t(B)))
=>
==(B,t(A))

::RULE
MATRIX:A,B
FLOAT:a

-(+(a,A),B)
=>
+(-(A,B),a)

::RULE
MATRIX:A,B
FLOAT:a

*(%*%(A,B),a)
=>
{
%*%(*(a,A),B)
}

::RULE
MATRIX:A,B
FLOAT:a

*(A,/(a,B))
=>
/(*(a,A),B)