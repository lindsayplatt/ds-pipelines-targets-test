I used this repo to try out the [`targets`](https://books.ropensci.org/targets/index.html) package by following along with the DS Pipelines courses. I saved the result of each of the pipelines courses in separate branches.

To follow along, I couldn't do the actual course in Git Learning Lab because I wasn't going to complete the exact steps it wanted me to complete. Instead, I followed along with the steps by manually stepping through the `.md` files. 

* [ds-pipelines-1 steps](https://github.com/USGS-R/ds-pipelines-1-course/tree/master/responses)
* [ds-pipelines-2 steps](https://github.com/USGS-R/ds-pipelines-2-course/tree/master/responses)
* [ds-pipelines-3 steps](https://github.com/USGS-R/ds-pipelines-3-course/tree/master/responses)

# Build pipelines-1 branch

To build this branch, run the following chunk of code. Three targets should build: `sb_csv_download`, `plot_data`, and `generate_plot`. You should end up with two new files in your repo: `1_fetch/out/model_RMSEs.csv` and `3_visualize/out/figure_1.png`.

```r
library(targets)
tar_make()
```
