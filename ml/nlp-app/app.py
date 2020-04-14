from flask import Flask,render_template,url_for,request,jsonify
import pandas as pd 
import pickle
import spacy
import re
import datetime as dt
from datetime import datetime
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.externals import joblib
nlp = spacy.load('en_core_web_sm')

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify(
        msg = "Welcome to python NLP"
    )

@app.route('/predict',methods=['POST'])
def predict():
	df= pd.read_csv("model-training-data.csv")
	df_data = df[["CONTENT","CLASS"]]
	# Features and Labels
	df_x = df_data['CONTENT']
	df_y = df_data.CLASS
    # Extract Feature With CountVectorizer
	corpus = df_x
	cv = CountVectorizer()
	X = cv.fit_transform(corpus) # Fit the Data
	from sklearn.model_selection import train_test_split
	X_train, X_test, y_train, y_test = train_test_split(X, df_y, test_size=0.33, random_state=42)
	#Naive Bayes Classifier
	from sklearn.naive_bayes import MultinomialNB
	clf = MultinomialNB()
	clf.fit(X_train,y_train)
	clf.score(X_test,y_test)
	#Alternative Usage of Saved Model
	# ytb_model = open("naivebayes_spam_model.pkl","rb")
	# clf = joblib.load(ytb_model)

	if request.method == 'POST':
		
		comment = request.json['comment']
		data = [comment]
		vect = cv.transform(data).toarray()
		my_prediction = clf.predict(vect)

	if my_prediction[0] == 1: # get previous requests
		print('get previous requests')
		predictionjson = jsonify(
        entent = 'show'
    )
	elif my_prediction[0] == 0: # new booking
		print('new booking')
		dic = dict([(x.label_, str(x)) for x in nlp(comment).ents])
		print(dic)
		if dic['DATE'] == 'today':
			bookDate = dt.date.today()
		elif dic['DATE'].find('tomorrow') != -1:
			bookDate = dt.date.today() + dt.timedelta(days = 1)
		
		# if dic['DATE'] != ''
		predictionjson = jsonify(
        entent = 'create',
				date = bookDate,
				time = datetime.strftime(datetime.strptime(dic['TIME'], "%I:%M %p"), "%H:%M")
    )
	else:
		print('someting different')
		predictionjson = jsonify(
        entent = 'undefined'
    )
	return predictionjson
	# return render_template('result.html',prediction = my_prediction)



if __name__ == '__main__':
	app.run(debug=True,host='0.0.0.0',port=6000)