import nltk
from nltk.chat.util import Chat, reflections
import sys  # Add this import

pairs = [
    [
        r"hi|hello|hey",
        ["Hello!", "Hi there!", "Hey!"]
    ],
    [
        r"what is your name?",
        ["I'm a chatbot created by Aliyan Kashmiri."]
    ],
    [
        r"how are you?",
        ["I'm doing well, thanks!", "All good!"]
    ],
    [
        r"(.*) your creator?",
        ["Aliyan Abid is my creator."]
    ],
    [
        r"bye|exit|quit",
        ["Goodbye!", "See you later!", sys.exit]  # This will close the program
    ],
]

def run_chatbot():
    print("Chatbot: Hello! Type 'bye', 'exit', or 'quit' to exit.")
    chatbot = Chat(pairs, reflections)
    
    while True:
        user_input = input("You: ")
        if user_input.lower() in ['bye', 'exit', 'quit']:
            print("Chatbot: Goodbye!")
            break  # This exits the loop and ends the program
        print("Chatbot:", chatbot.respond(user_input))

run_chatbot()