Hill Climbing Vigenere Cipher Breaker
=====================================

Usage
-----
- cd to the directory with the script
- Run ```julia```. All the following commands should be used in the REPL.
## To encode text
- ```plaintext = preprocess_text("""text_here""")```
- ```vigenere_encode(plaintext, "key_here")```
## To decode text
- ```ciphertext = """ciphertext_here"""``` The encoding preferably should have skipped over punctuation.
- ```vigenere_encode(plaintext, "key_here", true)```
## To crack text
- ```ciphertext = """ciphertext_here"""``` The encoding preferably should have skipped over punctuation.
- ```cracked_keys = crack_key(cipher, 30, 0.15, 5, 50, 0.1)```
    - Parameters, from left to right, are:
        - Max key length: The upper bound on the key length.
        - Epsilon: The chance that the algorithm explores nonoptimal choices. Increase this to encourage exploration.
        - Epochs: How many times the algorithm should restart. Each restart generates a new key.
        - Decay: A constant to multiply the epsilon by every cycle. Smaller values will result in faster decay. This is for simulating annealing.
    - The keys, along with their "scores", will be printed.
    - The keys will also be returned as an array of strings (duplicates will be removed).
- ```display_cracked_texts(ciphertext, cracked_keys)``` to view the results of the key.
