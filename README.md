# MATLAB code for analyzing infrared nerve block data

## Installation

```
git clone https://github.com/CWRUChielLab/NerveBlockAnalysis.git
cd NerveBlockAnalysis
git submodule update --init
mkdir data/hl_201605027
mkdir data/10.11.2016
```

Copy the AxoGraph data into the `data` subdirectories. See [ProcessAllCharts.m](ProcessAllCharts.m) for a list of the needed data files.

If you need to use SSH for write privileges, use the following to fix your remote URLS.
```
cd NerveBlockAnalysis
git remote set-url origin git@github.com:CWRUChielLab/NerveBlockAnalysis.git
rm -rf include/importaxographx .git/modules/include/importaxographx
git config submodule.include/importaxographx.url git@github.com:CWRUChielLab/importaxographx.git
git submodule update
```
