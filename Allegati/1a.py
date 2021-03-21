import numpy as np
import tensorflow as tf
from tensorflow_probability import distributions as tfd

tf.enable_eager_execution()

# Set values for the mixture
alphas = [0.6, 0.3, 0.1]
means = [30, 60, 120]
sigmas = [5, 3, 1]

# Use the tf.probability class
gm = tfd.MixtureSameFamily(
    mixture_distribution=tfd.Categorical(probs=alphas),
    components_distribution=tfd.Normal(
        loc=means,       
        scale=sigmas))

# Draw 1e5 random samples from the mixture distribution
prices = gm.sample(sample_shape=(int(1e5)), seed=42)

# Create a normal distribution with empirical mean & std. deviation
nd_empirical = tfd.Normal(loc=np.mean(prices), scale=np.std(prices))

print(np.mean(prices))
print(np.std(prices))