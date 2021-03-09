I used this repo to try out the [`targets`](https://books.ropensci.org/targets/index.html) package by following along with the DS Pipelines courses. I saved the result of each of the pipelines courses in separate branches.

To follow along, I couldn't do the actual course in Git Learning Lab because I wasn't going to complete the exact steps it wanted me to complete. Instead, I followed along with the steps by manually stepping through the `.md` files. 

* [ds-pipelines-1 steps](https://github.com/USGS-R/ds-pipelines-1-course/tree/master/responses)
* [ds-pipelines-2 steps](https://github.com/USGS-R/ds-pipelines-2-course/tree/master/responses)
* [ds-pipelines-3 steps](https://github.com/USGS-R/ds-pipelines-3-course/tree/master/responses)

# How I setup pipelines-2

I had already completed [the actual GitHub Learning Lab course](https://lab.github.com/USGS-R/scipiper-tips-and-tricks), so I went to [my course repo](https://github.com/lindsayplatt/ds-pipelines-2) and copied the `scipiper` pipeline code needed into this repo. I copied all of the `src/` files and the `remake.yml`. Then, I was ready to convert the `scipiper` pipeline into a `targets` pipeline.

# Build pipelines-2

I created code that shows how to recreate ds-pipelines-2 using `targets` exactly (`_targets_notasktable.R`), but I also tried taking it one step further and converting the ds-pipelines-2 into a task table-like pipeline (`_targets_tasktable.R`). Change which one of those files is commented out in `_targets.R` before building. Both create an object called `target_list` that contains all of the targets and is then called on in `_targets.R`.

Once you choose which of the version to use (mapped or not), run the following chunk of code. XXX targets should build: `1_fetch/out/site_data_SITENO.csv` (one for each site, so 5 total), `site_info`, `2_process/out/site_data_plot.rds`, and `"3_visualize/out/figure_1.png"`. Note that all of the directories need to be setup ahead of time; `tar_make()` will not create an `*/out/` folder and will throw an error if you don't have the correct directories.

Also note that the `download_nwis_site_data` function is setup to purposefully cause flaky download issues as a way of simulating internet flakiness during the pipeline builds. Unfortunately, I have yet to find a similar solution in `targets` to retrying targets as exists in `scipiper` with the `num_tries` argument to `loop_tasks`.


```r
library(targets)
tar_make()
```
