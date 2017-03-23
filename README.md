# MATLAB code for analyzing infrared nerve block data

## Installation

```
git clone https://github.com/CWRUChielLab/OpticalBlockAnalysis.git
cd OpticalBlockAnalysis
git submodule update --init
mkdir data/{10.11.2016,hl_201605017,hl_201605027,hl_201605031}
```

Copy the AxoGraph data into the `data` subdirectories. See [ProcessAllCharts.m](ProcessAllCharts.m) for a list of the needed data files.

If you need to use SSH for write privileges, use the following to fix your remote URLS.
```
cd OpticalBlockAnalysis
git remote set-url origin git@github.com:CWRUChielLab/OpticalBlockAnalysis.git
rm -rf include/importaxographx .git/modules/include/importaxographx
git config submodule.include/importaxographx.url git@github.com:CWRUChielLab/importaxographx.git
git submodule update
```
