# Solutions of Lecture 9

***

## Entropy

1. Suppose a password is chosen as a concatenation of four lower-case dictionary words, where each word is selected uniformly at random from a dictionary of size 100,000. An example of such a password is `correcthorsebatterystaple`. How many bits of entropy does this have?

The joint entrophy of $n$ random variables is:

$$H(X_1, ..., X_n) = -\sum_{x_1\in\mathfrak{X_1}}...\sum_{x_n\in\mathfrak{X_n}}P(x_1, ..., x_n)\log_2 [P(x_1, ..., x_n)].$$

In our case, the random variables are independent, follow an uniform distrbution and their associate sets have the same cardinality $M$, then:

$$P(x_1, ..., x_n) = P(x_1)... P(x_n) = \frac{1}{M^n}.$$

With the last expression and doing basic operations with the summatories is easy to obtain the following expression:

$$H(X_1, ..., X_n) = n\log_2 M.$$

In our particular case, $n=4, M=10^5$, so:

$$H = 4\log_2 10^5 \approx 66.4 \text{ bits}.$$

2. Consider an alternative scheme where a password is chosen as a sequence of 8 random alphanumeric characters (including both lower-case and upper-case letters). An example is `rg8Ql34g`. How many bits of entropy does this have?

The total number of alphanumeric characters are 62 (including lower and upper case), the assumptions made in the exercise 1 still hold here, however, $n=8 and M=62$ then:

$$H = 8\log_2 62 \approx 47.6 \text{ bits}.$$

3. Which is the strongest password? The first one since it has a higher entropy.

4. Suppose an attacker can try guessing 10,000 passwords per second. On average, how long will it take to break each of the passwords?

The number of possibilities are $M^n$, let be the ratio of passwords per second $P[s^{-1}]$ or $86400P[\text{days}^{-1}]$ and let be the days required to try all the possible passwords $D[\text{days}]$. In most casses, an attacker has not to try all the passwords but a fraction $f_p \in (0,1]$ of them, so if we change the interpretation of $D[\text{days}]$ to be the number of day required to try the fraction of passwords, its easy to come up with:

$$D = \frac{f_p M^n}{86400P}[\text{days}].$$

| Exercise | Length of password (n) | Cardinilaty (M) | Possibilities (M^n) | Fraction of possibilities (f_p) | Days              |
|----------|------------------------|-----------------|---------------------|---------------------------------|-------------------|
| 1        | $4$                    | $100000$        | $10^{20}$           | $1/2$                           | $5\times 10^{10}$ |
| 1        | $4$                    | $100000$        | $10^{20}$           | $1$                             | $10^{11}$         |
| 2        | $8$                    | $62$            | $2\times 10^{12}$   | $1/2$                           | $1\times 10^5$    |
| 2        | $62$                   | $62$            | $2\times 10^{12}$   | $1$                             | $2\times 10^{5}$  |
