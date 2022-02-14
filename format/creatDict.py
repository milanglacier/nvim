# %%
import pandas as pd
import numpy as np
import functools
import matplotlib.pyplot as plt
import seaborn as sns
import sklearn
import torch
import tensorflow as tf

pd_dir = dir(pd)
np_dir = dir(np)
np_linalg_dir = dir(np.linalg)
plt_dir = dir(plt)
functools_dir = dir(functools)
sns_dir = dir(sns)
sklearn_dir = dir(sklearn)
torch_dir = dir(torch)
tf_dir = dir(tf)

# %%
with open("python.dict", "a") as f:
    f.write("\n")
    for i in np_dir:
        f.write(i + '\n')


 

# %%