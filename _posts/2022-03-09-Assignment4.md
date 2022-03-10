---
layout: post
title: EPPS 6354 Assignment 4
---


### Question 3a: 
Consider the following query. Explain why appending natural join section in the from clause would not change the result. 
  **select** *course_id, semester, year, sec_id, * **avg** *(tot_cred)*   
  **from** *takes* natural join *student*
  **where** year = 2017
  **group by** *course_id, semester, year, sec_id*
  **having** count (*ID*) >= 2;
  
  #### Answer: 
  A natural join any attributes with the same name across the specified relations and only returns tuples where those attribute values match across relations. 
  The relations *takes* and *section* share almost all of the same attributes - course_id, sec_id, semester, year, and all of these relations should be identical across *section* and *takes*. The only common attribute between *student* and the other relations is *ID*. The relation *takes* does not add any new, common attributes that would unncessarily limit the results. 
  
  By contrast, adding a natural join with *course* would change the results, as both *course* and *student* have the attribute *dept_name*. The natural join would only return courses that the student took within their own department, and no courses taken in different departments. 
  
  We can test this in the online SQL interpreter provided with the book. 
  
  Fig 1: Code without the extra join
  ![A screenshot of code and results without extra join](https://shawnnstewart.github.io/images/WOExtraJoin.png "a screenshot")
  
  Fig 2: Code with the extra join
 ![A screenshot of code and results with extra join](https://shawnnstewart.github.io/images/WExtraSection.png "a screenshot")
 
### Question 3b
Write an SQL query using the university schema to find the ID of each student who has never taken a course at the university. Do this using no subqueries and no set operations (use an outer join). 

#### Answer

**select** *
**from** *student* **natural left outer join** *takes*
**where** *course_id* **is** *null*
