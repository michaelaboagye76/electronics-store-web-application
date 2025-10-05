from flask import Flask, render_template

app = Flask(__name__)

# Sample product data
products = [
    {"name": "Laptop", "price": "$800", "image": "images/laptop.jpeg"},
    {"name": "Microwave", "price": "$150", "image": "images/microwave.png"},
    {"name": "Smart TV", "price": "$500", "image": "images/tv.jpeg"},
    {"name": "Refrigerator", "price": "$700", "image": "images/fridge.png"}
]

@app.route('/')
def home():
    return render_template("index.html", products=products)

@app.route('/contact')
def contact():
    return render_template("contact.html")

if __name__ == '__main__':
    # Only for local testing
    app.run(host='0.0.0.0', port=5000)
