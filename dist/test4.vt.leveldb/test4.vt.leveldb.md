Test Summary
================

    [1] "Report Name: test4.vt.leveldb.md"

Summary Statistics from Raw Data
--------------------------------

-   List of expected columns in the jmeter output
-   List of labels selected for analysis (The kind of events to be analyzed)
-   Summary statistics of elapsed time (ms) for each label.

<!-- -->

    Input column names:
     timeStamp elapsed label responseCode responseMessage threadName dataType success bytes grpThreads allThreads Latency

    Value of 'label' used for analysis:
     PUT Perf Container

    $`elapsed for num_PUT_Perf_Container`
       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
        7.0    34.0    81.0   184.6   178.0 23810.0 

Results of Correlation and Linear Modeling
------------------------------------------

How strong is the linear correlation between time elapsed and the number of succesful events? This correlation is performed assuming the elapsed time for each event should be increasing as the cumulative number of events increases. A correlation coefficient near zero (&lt; 0.25) indicates no or very weak correlation.

``` r
cor_results
```

    $`~ elapsed + num_PUT_Perf_Container`

        Pearson's product-moment correlation

    data:  elapsed and num_PUT_Perf_Container
    t = 22.105, df = 989, p-value < 2.2e-16
    alternative hypothesis: true correlation is greater than 0
    95 percent confidence interval:
     0.5389738 1.0000000
    sample estimates:
          cor 
    0.5750517 

Answering the question, "Is the time elapsed significantly dependent on the number of successful events of the type being analyzed?" For example, is the time elapsed dependent on the number of successful "PUT Perf Container" events?

``` r
lmodels
```

    $`lm_forumla: elapsed ~ num_PUT_Perf_Container`

    Call:
    lm(formula = lm_formula, data = input_data, na.action = na.omit)

    Coefficients:
               (Intercept)  num_PUT_Perf_Container  
                 -81.50485                 0.01915  

Plots
-----

Plotting the time elapsed (ms) for each event by the cumulative number of events.

![](/home/grosscol/workspace/fcrepo_perf_analysis/build/test4.vt.leveldb_files/figure-markdown_github/bin_plots-1.png)

![](/home/grosscol/workspace/fcrepo_perf_analysis/build/test4.vt.leveldb_files/figure-markdown_github/dot_plots-1.png)

###### Template

*This report was generated from the template, 31-github-report.rmd*
