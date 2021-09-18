---
layout: post
title: Tufte's "Future of Data Analysis" 

---

Dr. Edward Tufte is well known for his eye-opening work on data visualization. In his keynote speech for the Microsoft Machine Learning & Data Science Summit 2016, he discusses many of the stumbling blocks in data visualization and analysis as well as the path forward, as he sees it. While data analysis and visualization have the potential to help us understand our world and make improvements to it, it is also very easy to go astray. 

>*The data may not contain the answer. And, if you torture the data long enough, it will tell you anything.*
>*-John W. Tukey*

Tukey describes the goal of data science as finding out something true and important about the world. Unfortunately, many of the things we find out in our data analysis may or may not be true. He points out that in recent years more and more issues have come to light, from the “replication problem” (studies that cannot be replicated to show the same results) and the overfitting problems that plagued the [Google Flu project](URL “https://time.com/23782/google-flu-trends-big-data-problems/”). He talks about several common issues in data analysis.

**You can find anything in 50 dimensions**
One of the issues with the Google Flu project was that it used a *lot* of variables. The more variables that are added in, the more potential there is for overfitting the model. Given enough variables (each of which may or may not be especially meaningful), the analysis can be made to show just about anything. Tufte described this by saying, “You can find anything you want in fifty dimensional space.” 

**Needle in the haystack**
Another common issue is publication bias, where a researcher may try many different experiments or analyses but only publish the favorable ones. If you run a couple analyses and find significant results, that suggests there’s something there. If you run a couple million analysis and find a few significant results, that’s just the luck of the draw. It’s the difference between finding a needle in a haystack because you spent hours looking, and finding a needle in a needle stack because that’s where needles are. 

**Your analysis is only as good as your data**
Tufte speaks briefly about the importance of the data generation process and how it is important for researchers to know where their data comes from. He recommends going into the field if at all possible to observe how the data are collected. If there is sampling bias or other types of bias in the collection method, then you can do all the analysis you want but your results will not be very useful or generalizable. 

All of these issues drive home the importance of solid research design, applying analytical thinking, and having proper checks and balances in place to verify your work. Long ago, Mark Twain said, “There are lies, damned lies and statistics.” He had a point. The numbers can be manipulated, the analysis fudged. But, with careful and conscientious work, we can also use data for good. 


Sources

Tufte, Edward. 2016. Keynote Session: Dr. Edward Tufte - The Future of Data Analysis. Available at https://channel9.msdn.com/Events/Machine-Learning-and-Data-Sciences-Conference/Data-Science-Summit-2016/MSDSS11
