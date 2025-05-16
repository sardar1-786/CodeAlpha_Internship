import yfinance as yf

portfolio = {}

def add_stock(symbol, shares):
    portfolio[symbol.upper()] = portfolio.get(symbol.upper(), 0) + shares

def remove_stock(symbol):
    portfolio.pop(symbol.upper(), None)

def show_portfolio():
    print("\nCurrent Portfolio:")
    total_value = 0
    for symbol, shares in portfolio.items():
        stock = yf.Ticker(symbol)
        price = stock.info.get('regularMarketPrice', 0)
        value = shares * price
        print(f"{symbol} - {shares} shares @ ${price:.2f} = ${value:.2f}")
        total_value += value
    print(f"Total Portfolio Value: ${total_value:.2f}\n")

def menu():
    while True:
        print("1. Add Stock\n2. Remove Stock\n3. Show Portfolio\n4. Exit")
        choice = input("Choose an option: ")
        if choice == '1':
            symbol = input("Enter stock symbol: ")
            shares = int(input("Enter number of shares: "))
            add_stock(symbol, shares)
        elif choice == '2':
            symbol = input("Enter stock symbol to remove: ")
            remove_stock(symbol)
        elif choice == '3':
            show_portfolio()
        elif choice == '4':
            break
        else:
            print("Invalid choice.")

menu()
