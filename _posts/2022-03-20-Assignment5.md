---
layout: post
title: EPPS 6354 Assignment 5
---

### Question 2
Construct an E-R diagram for a hospital with a set of patients and a set of medical doctors. Associate with each patient a log of the various tests and examinations conducted (Hint: use draw.io to draw the diagram with relationship sets).  


#### Answer

![A schema diagram](https://shawnnstewart.github.io/images/Assignment5Example.png "a schema")

### Question 3
We can convert any weak entity set to a strong entity set by simply adding appropriate attributes. Why, then, do we have weak entity sets?  

#### Answer
We use weak entity sets to make our databases more efficient and less redundant. 


### Question 4A, SQL exercise
Consider the employee database: 

  ![A schema diagram](https://shawnnstewart.github.io/images/Assignment5ExampleSchema.png "a schema")
  

where the primary keys are underlined. Give an expression in SQL for each of the following queries. (Hint: use from employee as e, works as w, company as c, manages as m)

**i.Find ID and name of each employee who lives in the same city as the location of the company for which the employee works.**

**select** *e.ID, e.person_name*  

**from** *employee as e, company as c, works as w*  

**where** *e.city = c.city* and  
          *w.ID=e.ID* and  
          *c.company_name = w.company_name*  

**ii.Find ID and name of each employee who lives in the same city and on the same street as does her or his manager.**  
**select** *a.person_name*  

**from** *employee as a, employee as b, manages as m*  

**where** *a.ID = m.ID* and *b.id = m.manager_id* and *a.city = b.city* and *a.street = b. street*  

In this case, the relation *employee* is involved twice, once to pull out the employee's information and once to pull out the manager's information, so we create two intances of the relation by giving it two aliases in the **from** statement.  

**iii.Find ID and name of each employee who earns more than the average salary of all employees of her or his company.**

**select** *e.ID, e.person_name* 
**from** *works* as *a*, *employee* as *e* 
**where** *salary* >  
(**select** avg(*salary*) 
**from** *works* as *b* 
**where** *a.company-name = b.company-name) 

### Question 4B
Consider the following SQL query that seeks to find a list of titles of all courses taught in Spring 2017 along with the name of the instructor.
select name, title
from instructor natural join teaches natural join section natural join course
where semester = 'Spring' and year = 2017

What is wrong with this query? (Hint: check book website)

#### Answer
Although this code will compute an answer, it will not give us what we're looking for. Natural joins will match relations on every attribute that appears in more than one relation. Since *dept_name* appears in both *course* and *instructor*, it will match department names when joining the relations. Hence, it will only show a list of courses that instructors teach in their own departments. 
