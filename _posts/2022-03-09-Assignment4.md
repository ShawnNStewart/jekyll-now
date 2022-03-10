---
layout: post
title: EPPS 6354 Assignment 4
---

### Question 1: 
Explain the difference between a weak and a strong entity set.  Use an example other than the one in Chapter 6 to illustrate.

#### Answer

A strong entity set has a primary key and is not dependent on any other set in the schema. It stands alone. A weak entity set does not have a primary key. Instead it has a "discriminator." Relationship sets betweeen a weak and strong entity set use the primary key fo the strong entity set and the discriminator of the weak entity set to form the primary key for the relationship schema. 

As an example, let's consider a company database that has data on employees and their dependents. The *employee* relation could be a strong entity set (including a primary key of employee ID), while the *dependent* relation could be a weak entity set, including only the dependent name which is used as the discriminator. The relationship set *family* could connect these two entity sets to identify which family members go with which employee. Even without this relationship set, the *employee* relation is still useful and can identify unique tuples. However, the weak entity set is dependent on the relationship set to help define its unique tuples. 


### Question 2
Design an E-R diagram for keeping track of the scoring statistics of your favorite sports team. You should store the matches played, the scores in each match, the players in each match, and individual player scoring statistics for each match. Summary statistics should be modeled as derived attributes with an explanation as to how they are computed. (Consult: https://www.db-book.com/db7/practice-exer-dir/PDF-dir/6s.pdf) 

a)Draw the E-R diagram using draw.io
b)Expand to all teams in the league (Hint: add team entity)

#### Answer 

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
