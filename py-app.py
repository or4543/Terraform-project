#py-app
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'  # SQLite database
db = SQLAlchemy(app)

class Data(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    value = db.Column(db.Float, nullable=False)
    time = db.Column(db.String(50), nullable=False)

@app.route('/process_data', methods=['POST'])
def process_data():
    try:
        data = request.get_json()
        name = data.get('name')
        value = data.get('value')
        time = data.get('time')

        # Create a new Data record and insert it into the database
        new_data = Data(name=name, value=value, time=time)
        db.session.add(new_data)
        db.session.commit()

        # You can process the data here as needed.
        # For now, let's just return the received data as JSON.
        response_data = {
            'name': name,
            'value': value,
            'time': time
        }

        return jsonify(response_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    db.create_all()
    app.run(debug=True)
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'  # SQLite database
db = SQLAlchemy(app)

class Data(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    value = db.Column(db.Float, nullable=False)
    time = db.Column(db.String(50), nullable=False)

@app.route('/process_data', methods=['POST'])
def process_data():
    try:
        data = request.get_json()
        name = data.get('name')
        value = data.get('value')
        time = data.get('time')

        # Create a new Data record and insert it into the database
        new_data = Data(name=name, value=value, time=time)
        db.session.add(new_data)
        db.session.commit()

        # You can process the data here as needed.
        # For now, let's just return the received data as JSON.
        response_data = {
            'name': name,
            'value': value,
            'time': time
        }

        return jsonify(response_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    db.create_all()
    app.run(debug=True)

