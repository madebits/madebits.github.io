#Key Derivation Functions

2016-02-24

<!--- tags: encryption -->

[Key derivation functions](https://en.wikipedia.org/wiki/Key_derivation_function) (**KDF**)s are used to generate one way *keys* from user provided passwords. KDFs are usually in form shown below and serve several related purposes:

```
key = KDF(password, salt, options)
```

1. KDF increases the entropy of `password`. Usually `key` is longer (has more *bits* of information) that `password`. KDF will use both `password` and a random `salt` as additional entropy source to generate the `key`. The random `salt` is not a secret and its size should be optimally same as that of `key`. In password storage case, both `salt` and `key` (treated as one way hash) are stored. In data encryption case, only `salt` is stored (along with other data, such as *initialization vector*) and `key` is used as encryption key.
2. KDF slows down `password` space enumeration. If `password` has lower entropy than `key`, then to brute force decryption (or to find an original password in the case of password storage), it is always faster to enumerate the `password` space rather than the `key` space. To slow the process down, it is preferable to have a KDF that is costly to compute. This is the main difference of a KDF from a *cryptographically secure hash* (**CSH**) function. CSHs are desirable to be fast to compute. KDF, while making often use of CSHs internally, must be hard to compute. KDF should be feasible to compute one result, but unfeasible to enumerate the whole `password` space. Optimally, KDF makes enumeration of `password` space comparable to enumerating the `key` space. Usually `options` are used in a KDF to specify the computation cost.
3. KDF enable `password` reuse. Same `password` combined with different `salt`s will result in different `key`s. We can encrypt data safely with different `key`s using same `password`.

##KDF Calculation Cost

Cost in computing is measured in terms of **time** and **memory** spent (needed). KDFs, such as, [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2) use computation time as cost, by producing a sequence of intermediate results. To calculate `key` from `password` all the sequence of operations (usually a CSH) has to be carried out. KDF `options` in this case take the form of *iteration count*, the bigger the more expensive the calculation is. [scrypt](https://en.wikipedia.org/wiki/Scrypt) and recent alternatives, such as, [Argon2](https://en.wikipedia.org/wiki/Argon2) explore both time and memory and their `options` can configure both of them.

##The Achilles Heel of KDFs

The main weakness of KDFs are the cost `options`, because the cost varies with passing of time. The cost should be set to the *maximum* amount (of time and / or memory) that user is willing to wait for each KDF call in the slowest system. As hardware development advances over time so does the affordable maximum cost. An acceptable cost for today (either time and / or memory) is too few for tomorrow. KDFs are good to protect data today. Old (encrypted) data become more and more vulnerable as the time goes on (this is why it makes sense to store adversary old encrypted data indefinitely). So, while KDFs are good and modern cryptography cannot be imagined without them, nothing is in long term as safe as a long random `password`.

##Prefer Long Random Passwords

Ideally, a good `password` that can better resist time, should contain at least as much entropy as the `key`. If this is the case, then it infeasible to brute-force attack the `password` space. For example, when using ANSI letters and numbers we have around $$$2^{6}$$$ possibilities for character. To match the lowest AES key possible search space of $$$2^{128}$$$, we need random passwords of around $$$22$$$ characters long. Any non-randomness in password reduces its entropy. If we use a password made from a list of $$$2^{12}$$$ words, we need it to contain at least $$$10$$$ random words. And, if we use contents (hashes) of $$$2^{10}$$$ available files (such as, images) as password, we need to select around $$$13$$$ such files at random to get same search space size as the AES key. 

Even if the search space of a `password` is same of that a `key`, it still makes sense to brute-force the `password` space, in hope the same `password` is reused. A long random `password` in combination with a KDF is, however, less likely to be broken by brute-force as search space and cost are too large. Given the `password` is a black-box to a brute-force attacker, the `password` length matters more that its entropy in a non-ideal case. When having a choice, a longer `password` even if it contains repetitive information is better than a shorter one with unique information.

##Using KDFs and Passwords

Most KDF implementations and code examples use defaults for `options` that are outdated by time you look at them. Always experiment to find the maximum KDF cost you can afford to spend today. Store the cost `options` along with `salt` and regularly increase cost (either automatically, or at least manually). Ask that the systems you use do this.

If you can afford it, reprocess old encrypted data or stored `keys` regularly over time to using bigger costs. This is of use only for data you are sure no one else has already a copy. One way to re-process massive encrypted data, it to use the KDF `key` to encrypt another random *key* you use for the actual encryption. Then only the encryption key of the data needed to be re-encrypted during reprocessing.

Offer users guidance to select long (and relatively random) passwords, for example by combining together different ways of password creation (words from a dictionary, file CSHs, user provided text, biometry, etc).

<ins class='nfooter'><a id='fnext' href='#blog/2016/2016-02-17-Sharing-Local-Folders-Over-Remote-Desktop.md'>Sharing Local Folders Over Remote Desktop</a></ins>
