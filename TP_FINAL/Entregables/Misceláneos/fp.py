# Imports
import pandas as pd
from fxpmath import Fxp

row_i = []
slope = 1/1.64676025805716

for e in range(1,25):
    a = Fxp(slope, 0, e, e-1)
    diff = slope - a.real
    diff_percentage = diff * 100 / slope
    mult = a.real / a.precision
    row = [e-1, slope, a.real, diff, diff_percentage, mult]
    row_i.append(row)

df = pd.DataFrame(row_i, columns = ['WL', 'Gain OSR 1', 'FP', 'Difference', 'Diff %', 'MULT'])

print(df)
