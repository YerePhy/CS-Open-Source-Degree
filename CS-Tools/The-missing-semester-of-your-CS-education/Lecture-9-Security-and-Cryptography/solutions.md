# Solutions of Lecture 9

***

## Entropy

1. Suppose a password is chosen as a concatenation of four lower-case dictionary words, where each word is selected uniformly at random from a dictionary of size 100,000. An example of such a password is `correcthorsebatterystaple`. How many bits of entropy does this have?

The joint entrophy of $n$ random variables is:

$$H(X_1, ..., X_n) = -\sum_{x_1\in\mathfrak{X_1}}...\sum_{x_n\in\mathfrak{X_n}}P(x_1, ..., x_n)\log_2 [P(x_1, ..., x_n)].$$

In our case the random variables are independent, follow an uniform distrbution and their associate sets have the same cardinality $M$, then:

$$P(x_1, ..., x_n) = P(x_1)... P(x_n) = \frac{1}{M^n}.$$

With the last expression and doing basic operations with the summatories is easy to obtain the following expression:

$$H(X_1, ..., X_n) = n\log_2 M.$$

In our particular case, $n=4, M=10^5$, so:

$$H = 4\log_2 10^5 \approx 66.4 bits.$$

