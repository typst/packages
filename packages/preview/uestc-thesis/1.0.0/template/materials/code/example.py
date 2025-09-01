import matplotlib.pyplot as plt
import numpy as np

# Generate random data
data = np.random.randn(100)

# Plot a histogram
plt.hist(data, bins=20, color='skyblue', edgecolor='black')
plt.title('Histogram Example')
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.show()