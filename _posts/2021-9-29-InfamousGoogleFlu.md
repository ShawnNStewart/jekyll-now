---
layout: post
title: The Infamous Google Flu
---
Every data science student these days has heard of Google Flu Trends, which debuted to great acclaim in 2009 and quietly shuttered in disgrace in 2014. The idea behind Google Flu was an appealing one – harness the power of Big Data to “nowcast” flu levels better than the CDC. And at first, it seemed like it was working. However, as the experiment continued it became clear that the Google Flu model was overfitted and overparameterized, causing it to grossly overestimate the rates of flu in future years. 

Big Data has become a catch phrase and it’s easy to think of it as a silver bullet. Big Data can fix anything, or so we’d like to think. This is what Lazer et. al. call “big data hubris” – viewing Big Data as a substitute for more traditional analysis, as opposed to a powerful supplement that can add value to existing methods. This is the first place that Google Flu failed. As Lazer et. al. show, a more traditional lagged model actually outperformed Google Flu. Big Data by itself isn’t a cure-all – but the merger of traditional analytics with Big Data has the potential to create something powerful and useful.

Google also fell prey to overfitting. The way Google Flu worked was by searcing through tens of millions of search terms to find terms that fit to less than 2000 data points. When working with a pool that large, the chances of finding random terms that fit the model (but are actually unrelated) is very high. Google even manually excluded some terms that were obviously unrelated (apparently the Google Flu algorithm, in addition to picking up flu-related terms, picked up references to high school basketball)(Lazer et. al. 2014). 

Google Flu Trends also had issues with replicability and transparency. Google never released enough information about their algorithm for it be replicated, and refused to even disclose the parameters used in the algorithm. All we know is that they used around 45 parameters, leading to an overparameterization problem. 

After failing to predict flu trends for several years after its inception, Google Flu Trends shut down. While Google Flu failed to help us understand flu season trends, it did put a spotlight on some of the common issues with Big Data projects. Hopefully the parable of Google Flu with help future data scientists and researchers to do better work, with more reliable results. 

Sources

Lazer, D., Kennedy, R., King, G., & Vespignani, A. (2014). The Parable of Google Flu: Traps in Big Data Analysis. Science (American Association for the Advancement of Science), 343(6176), 1203–1205. https://doi.org/10.1126/science.1248506

