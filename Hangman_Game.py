import random

# words = ["UMBERALLA", "COMPUTER", "SMARTPHONE","CAR"]
f = open("new.txt", "r")
data = f.readline()
words = data.split()
word = random.choice(words)
word = word.upper()

print("Welcome to the Hangman Game")
total_chances = 7
guessed_word = "-"*len(word)
while total_chances != 0:
    print(guessed_word)
    letter = input("Guess a letter: ").upper()
    if letter in word: 
        for index in range(len(word)):
            if word[index] == letter:
                guessed_word = guessed_word[:index] + letter +guessed_word[index+1:]
        if guessed_word == word:
            print("Congratulation you won!!")
            break
    else:
        total_chances -= 1
        print("Incorrect guess")
        print("The remaining chances are: ", total_chances)
        
else:
    print("Game Over!")
    print("You Lose!")
    print("All chances are exhausted")
    print("The correct word is ", word)