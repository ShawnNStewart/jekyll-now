---
title: A Look at Literate Programming
layout: post
---
Every beginning programmer is told, emphatically – comment your code! Whether or not we heed this advice can make the difference between creating a clean, reusable and updateable piece of code or a jumbled mess that is nearly impossible to edit or debug. 

Donald Knuth’s concept of literature programming goes a step further. Literate programming combines source code with explanations in plain English, making it even easier to reproduce and edit others’ (or our own) work in the future. In the world of data science and open research, this is invaluable. 

>*“An individual block of code takes moments to write, minutes to debug, and can last forever without being touched again. It’s only when you visit code written yesterday that having code written in a clear, consistent style becomes extremely useful. Understandable code frees up your mental bandwidth from having to puzzle out inconsistencies, making it easier to maintain and enhance projects of all sizes.”*
> *— Daniel Roy Greenfeld, Python Django developer and author*

Clearly other people in the field agree, as we’ve seen the growth of packages like RMarkdown and Bookdown. It’s now possible to write entire papers and reports with R. There are practical benefits to having your paper, source code, and outputs intertwined in this way. For example, it eliminates the need to flip between the code and the paper, making it easier to see how the two relate to each other (Bowers & Voor 2016). There are also benefits, such as allowing the program to assign figure numbers. Instead of tediously updating all the figure numbers if you decide to move something, they’re automatically generated.

I would argue that the biggest benefits to literate programming are the clarity it gives readers and the ease with which fellow researchers can replicate and extend the work. After all, what is the point of publishing findings if not to engage in a dialogue with our community and provide a stepping stone to build something even better. The best way to do that is to make sure your methods are clear and your code and outputs are reproducible. 

References

Bowers, J., & Voors, M. (2016). How to improve your relationship with your future self/Como mejorar su relacion con su futuro yo. Revista de ciencia política (Santiago), 36(3), 829–848.
