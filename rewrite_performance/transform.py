import pandas as pd
import numpy as np

data = [
    pd.read_csv('./L2SVM_opt.csv'),
    pd.read_csv('./L2SVM_nopt.csv'),
    pd.read_csv('./MultiLogReg_opt.csv'),
    pd.read_csv('./MultiLogReg_nopt.csv'),
]

for t in data:
    t['Total'] /= 5
    t['Calls'] /= 5
    print(t.to_latex(index=False))