import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import matplotlib.ticker as ticker

test_name = 'multInv'
sparsity = 0.01
save = True

# Sort the data based on the desired order
var_order = [1000, 5000, 10000, 1000000, 5000000, 10000000]
#mode_order = ['Std', 'Gen', 'Base', 'GenBase']
mode_order = ['Std', 'Gen']
include = ['Std', 'Gen']
format = "M"



####################
if format == "n":
    formatting = lambda x, _: x
if format == "K":
    formatting = lambda x, _: f'3x{int(x/1_000)}K'
if format == "K^2":
    formatting = lambda x, _: f'{int(x/1_000)}Kx{int(x/1_000)}K'
elif format == "M":
    formatting = lambda x, _: f'3x{int(x/1_000_000)}M'
elif format == "M^2":
    formatting = lambda x, _: f'{int(x/1_000_000)}Mx{int(x/1_000_000)}M'

# Read dataframe
data = pd.read_csv(f'../resultsMB/mb_{test_name}_{sparsity}.csv')

# Filter the data based on the desired MODEs
data = data[data['MODE'].isin(include)]

data['VAR'] = pd.Categorical(data['VAR'], categories=var_order, ordered=True)
data['MODE'] = pd.Categorical(data['MODE'], categories=mode_order, ordered=True)

# Re-sort the DataFrame based on the categorical ordering
sorted_data = data.sort_values(['VAR', 'MODE'])

# Pivot the data to prepare for grouped bar plot
pivoted_data = data.pivot(index='VAR', columns='MODE', values='RESULT')

# Define positions and bar width
bar_width = 0.2
positions = np.arange(len(pivoted_data))

plt.figure(figsize=(8, 6))

# Plot each MODE group
for i, mode in enumerate(pivoted_data.columns):
    plt.bar(positions + i * bar_width, pivoted_data[mode], width=bar_width, label=mode)

# Format the plot
plt.xticks(positions + bar_width * (len(pivoted_data.columns) / 2 - 0.5), pivoted_data.index)
plt.xlabel('Data Size', fontsize=18)
plt.ylabel('Time [ms]', fontsize=18)
plt.legend(title='MODE')
plt.yscale('log')
plt.ylim(0.1, None)
plt.legend(fontsize=16, loc='lower right')  # Add a legend to distinguish the two lines
plt.xticks(fontsize=16)
plt.yticks(fontsize=16)

# Customize the x-axis ticks to show formatted labels
formatted_labels = [formatting(var, None) for var in pivoted_data.index]
plt.xticks(positions + bar_width * (len(pivoted_data.columns) / 2 - 0.5), formatted_labels, fontsize=16)

if save:
    plt.savefig("../figuresMB/" + test_name + "_" + str(sparsity) + ".pdf")

plt.show()