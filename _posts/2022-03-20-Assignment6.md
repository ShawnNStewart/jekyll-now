---
layout: post
title: EPPS 6354 Assignment 6
---

#### Question 1

Look up websites containing the following data representations
a)Using JSON
b)Using XML

Analyze the websites in terms of structure and composition. Name the technology/methods use for creating the web database.

#### Answer

The UT Dallas ISSO webpage uses Amazon Connect to serve live chat functionality. The Amazon Connect instance is configured to store all chat logs in an S3 bucket in Amazon Web Services, and the chat logs are stored as JSON files. Things such as date, agent, and chat text are stored and can be retrieved as needed through the Amazon Connect dashboard by staff members. The Amazon Connect dashboard provides user-friendly access to information stored in the database, and is used by staff members (not students or other clients sending chat messages). For example, through the dashboard a supervisor can pull a list of all chats answered by a particular agent, including their time stamps and chat details, for review. 

The ISSO also uses a database called Sunapsis to manage international student records. Staff members have the ability to use a graphical interface called the "custom report builder" to query the database, and results are returned in XML format. In this database, there is no function within the graphical interface that displays results - the results are always output as an XML formatted file. 

### Question 2 part i
Express the following query in SQL using no subqueries and no set operations. (Hint: left outer join)
**select** *ID*
**from** *student*
**except** 
**select** *s.id*
**from** *advisor*
**where** *i.ID* is not null


#### Answer

**select** s.ID
**from** *student* left outer join *advisor* 
**where** *advisor.id* is null

### Question 2 part ii
Using the university schema, write an SQL query to find the names and IDs of those instructors who teach every course taught in his or her department (i.e., every course that appears in the course relation with the instructor’s department name). Order result by name. 

#### Answer

**select** *i.id, i.name*
**from** *instructor i*
  **join** *teaches t on i.id = t.id*
**group by** *i.id, i.deptname*
**having** count(distinct *course_id*) = (
  **select** count(distinct *course_id*)
  **from** *course c* 
  **where** *c.deptname = i.deptname*)
**order by** *i.name*
