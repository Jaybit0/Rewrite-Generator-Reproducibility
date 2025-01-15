import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

# This script must be executed from this directory

test_name = 'sumScalarMult_1'

include_gen = True
include_std = True
include_base = True
include_additional = ['GenBase']
log_y = False
log_x = False
granular_grid = True
format = "M"

save = True

from_spark = False


if format == "K":
    formatting = lambda x, _: f'3x{int(x/1_000)}K'
elif format == "M":
    formatting = lambda x, _: f'3x{int(x/1_000_000)}M'

######################
spark_suffix = '/part-00000' if from_spark else ''

if include_gen:
    data_opt = pd.read_csv('../results/' + test_name + '_Gen.csv' + spark_suffix, header=None)
if include_std:  
    data_nopt = pd.read_csv('../results/' + test_name + '_Std.csv' + spark_suffix, header=None)
if include_base:
    data_nnopt = pd.read_csv('../results/' + test_name + '_Base.csv' + spark_suffix, header=None)

mdata = []

for add in include_additional:
    data_add = pd.read_csv('../results/' + test_name + '_' + add + '.csv' + spark_suffix, header=None)
    data_add.columns = ['time', 'size']
    mdata.append((add, data_add['time']/20, data_add['size']))

if include_gen:
    data_opt.columns = ['time', 'size']
if include_std:
    data_nopt.columns = ['time', 'size']
if include_base:
    data_nnopt.columns = ['time', 'size']

# Step 2: Extract x and y columns
if include_gen:
    x_opt = data_opt['time']/20  # Replace with the actual column name for x values
    y_opt = data_opt['size']  # Replace with the actual column name for y values

if include_std:
    x_nopt = data_nopt['time']/20  # Replace with the actual column name for x values
    y_nopt = data_nopt['size']  # Replace with the actual column name for y values

if include_base:
    x_nnopt = data_nnopt['time']/20  # Replace with the actual column name for x values
    y_nnopt = data_nnopt['size']  # Replace with the actual column name for y values

# Step 4: Plot both lines with flipped axes
plt.figure(figsize=(8, 6))  # Optional: Set the figure size

if include_gen:
    # Plot the first line (optimized data) with flipped axes
    plt.plot(y_opt, x_opt, label='Gen', marker='o')

if include_std:
    # Plot the second line (non-optimized data) with flipped axes
    plt.plot(y_nopt, x_nopt, label='Std', marker='s')

if include_base:
    # Plot the second line (non-optimized data) with flipped axes
    plt.plot(y_nnopt, x_nnopt, label='Base', marker='v')

for add in mdata:
    plt.plot(add[2], add[1], label=add[0], marker='^')

# Customize the x-axis ticks to show 1M, 2M, etc.
formatter = ticker.FuncFormatter(formatting)
plt.gca().xaxis.set_major_formatter(formatter)

if granular_grid:
    # Add major and minor grids
    plt.grid(which='major', linestyle='-', linewidth=0.75, alpha=0.8)  # Major grid
    plt.grid(which='minor', linestyle='--', linewidth=0.5, alpha=0.5)  # Minor grid

# Step 5: Customize the plot
#plt.title('Optimized vs Non-Optimized Data (Flipped Axes)')  # Add a title
plt.xlabel('Dimensions', fontsize=18)  # New x-axis label (was y-axis originally)
plt.ylabel('Time [ms]', fontsize=18)  # New y-axis label (was x-axis originally)
plt.legend(fontsize=16)  # Add a legend to distinguish the two lines
plt.xticks(fontsize=16)
plt.yticks(fontsize=16)
plt.grid(True)  # Optional: Add a grid

if log_x:
    plt.xscale('log')

if log_y:
    plt.yscale('log')

if save:
    plt.savefig("../figures/" + test_name + ".pdf")

# Show the plot
plt.show()