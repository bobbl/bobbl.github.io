---
layout: post
title:  "ftoa: Convert a binary floating point number to a minimal decimal string"
date:   2023-07-03 00:00:00 +0200
categories: fp
---




The minimal decimal representation of a floating point number is as short as
possible and when converted back to a binary floating point number it must be
identical to the original number (round-trip property).

Such an unambiguous decimal representation is necessary when converting floats
from binary to text and back. For example when using CSV as intermediate format
or when using SQL to write a binary float to a database.

With `sprintf("%f")` or similar C++ routines the output is neither distinct for
every floating point number nor minimal. Several algorithms were developed over
the years:



History
-------



### Dragon4 (1990)

Paper: [How to print floating-point numbers accurately](https://lists.nongnu.org/archive/html/gcl-devel/2012-10/pdfkieTlklRzN.pdf)
by Guy Steele and Jon White.

Source code can be found in the grisu3 or Errol3 repository.

First algorithm for a minimal decimal representation. Slow due the use of very
large integer arithmetics (bignums).



### grisu3 (2010)

Paper: [Printing Floating-Point Numbers Quickly and Accurately with Integers](https://dl.acm.org/doi/abs/10.1145/1806596.1806623)
by Florian Loitsch.

Reference implementation: <https://github.com/google/double-conversion>

Much faster than Dragon4 due to the use of small fixed length integers.
However, for 0.5% of the numbers the result is either not minimal (grisu2) or
the conversion is rejected and Dragon4 must be used (grisu3).



### Errol3 (2016)

Paper: [Printing Floating-Point Numbers - An Always Correct Method](https://dl.acm.org/doi/10.1145/2837614.2837654)
by Marc Andrysco, Ranjit Jhala and Sorin Lerner.

Reference implementation: <https://github.com/marcandrysco/Errol>

Uses Knuth's double-double floating point arithmetics instead of fixed length
integers. In the first version of the paper the evaluation was incorrect and
indicated that Errol3 is faster than grisu3. In the corrected version it is
slower, but always finds the minimal representation. In the github repo Errol4
can be found which is even faster than grisu3, but Errol4 is not mentioned in
the paper.



### Ryu (2018)

Paper: [Ryū: fast float-to-string conversion](https://dl.acm.org/citation.cfm?doid=3296979.3192369)
by Ulf Adams.

Reference implementation: <https://github.com/ulfjack/ryu>

Faster than the previous algorithms, but requires much larger look-up tables.



### Schubfach (March 2020)

Paper: [The Schubfach way to render doubles](https://drive.google.com/open?id=1luHhyQF9zKlM8yJ1nebU0OgVYhfC6CBN)
by Raffaello Giulietti.

Java implementation by the author: <https://github.com/c4f7fcce9cb06515/Schubfach/blob/master/todec/src/math/DoubleToDecimal.java>

C++ Implementation by Drachennest: <https://github.com/abolz/Drachennest/blob/master/src/schubfach_64.cc>

Some similarities with Ryu, but faster. Trailing zeros must be truncated.



### Dragonbox (September 2020)

[Dragonbox: A New Floating-Point Binary-to-Decimal Conversion Algorithm](https://github.com/jk-jeon/dragonbox/blob/master/other_files/Dragonbox.pdf)
by Junekey Jeon.

Reference implementation: <https://github.com/jk-jeon/dragonbox>

Brief implementation by Drachennest: <https://github.com/abolz/Drachennest/blob/master/src/dragonbox.cc>

Based on Schubfach, some optimizations from grisu are used to reduce the number
of expensive 128-bit x 64-bit multiplications. As of 2023 the fastest algorithm.
Both paper and implementation are extensive but hard to follow.



Comparison
----------

<https://github.com/abolz/Drachennest>




